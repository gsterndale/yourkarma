module YourKarma
  class CLI
    class Reporter
      DEFAULT_OPTIONS = {
        io: STDOUT
      }
      attr_accessor :options

      def initialize(options = {})
        self.options = DEFAULT_OPTIONS.merge(options)
      end

      def report_header
        write "| Connect | Speed | Battery | Charging |\n"
        write "+---------+-------+---------+----------+\n"
      end

      def report_progress
        write '.' if reported?
      end

      def report_error
        write '*' if reported?
      end

      def report_on(device, benchmark)
        write options[:tail] ? "\n" : "\r" if reported?
        @reported = true
        write [
          '',
          pad( 9,   connect(device, benchmark)),
          pad( 7,     speed(device, benchmark)),
          pad( 9,   battery(device, benchmark)),
          pad(10,  charging(device, benchmark)),
          " "
        ].join "|"
        status_code(device, benchmark)
      end

      def report_quit(code)
        write "\n"
        code || 1
      end

      private

      def reported?
        !!@reported
      end

      def connect(device, benchmark)
        return '' unless device
        case
        when benchmark
          "-=≡"
        when device.valid_ipaddress?
          "-="
        else
          "-"
        end
      end

      def speed(device, benchmark)
        unless benchmark
          return device && device.valid_ipaddress? ? ":(" : ":X"
        end
        case benchmark * 100
        when 0..20
          "(⌐■_■)" # ":0"
        when 20..40
          ":)"
        when 40..70
          ":|"
        else
          "(ಠ_ಠ)" # ":["
        end
      end

      def battery(device, benchmark)
        return '[?????}' unless device && device.batterypower
        percent = device.batterypower.to_f / 100.0
        length = 5
        tics = (length * percent).floor
        "[#{ '#' * tics}#{ ' ' * (length - tics)}}"
      end

      def charging(device, benchmark)
        return '?' unless device
        device.charging ? "=D----" : "X"
      end

      def bandwidth(device, benchmark)
        "1.3 GB"
      end

      def status_code(device, benchmark)
        device && benchmark ? 0 : 3
      end

      def pad(size, meat)
        meat ||= ''
        space = size - meat.size
        left  = (space.to_f / 2).ceil
        right = (space.to_f / 2).floor
        [
          ' ' * left,
          meat,
          ' ' * right
        ].join
      end

      def write(string)
        options[:io].print string
      end
    end
  end
end
