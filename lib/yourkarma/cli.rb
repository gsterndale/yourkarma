require 'optparse'
require_relative 'client'
require_relative 'device'
require_relative 'benchmarker'

module YourKarma
  class CLI
    attr_accessor :options

    def self.run(io, arguments)
      options = { io: io }
      options.merge! ArgumentParser.new.parse(arguments)
      self.new(options).run
    rescue ArgumentParser::InvalidOption => e
      options[:io].puts e
      1
    end

    def initialize(options = {})
      self.options = options
    end

    def run
      client      = Client.new(options)
      benchmarker = Benchmarker.new(options)
      reporter    = Reporter.new(options)
      reporter.report_header
      iterations = options[:iterations] || Float::INFINITY
      code = 1
      (1..iterations).each do
        begin
          code = run_once(client, benchmarker, reporter)
        rescue Interrupt
          break
        end
      end
      reporter.report_quit(code)
    end

    private

    def run_once(client, benchmarker, reporter)
      begin
        attrs     = client.get
        reporter.report_progress
        device    = Device.new(attrs)
        benchmark = benchmarker.benchmark
      rescue Client::ConnectionError, Benchmarker::ConnectionError
        reporter.report_error
      end
      reporter.report_on(device, benchmark)
    end

    class Reporter
      DEFAULT_OPTIONS = {
        io: STDOUT
      }
      attr_accessor :options

      def initialize(options = {})
        self.options = DEFAULT_OPTIONS.merge(options)
      end

      def report_header
        write "| Connect | Speed | Battery | Charging | Bandwidth |\n"
        write "+---------+-------+---------+----------+-----------+\n"
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
          pad(11, bandwidth(device, benchmark)),
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

    class ArgumentParser
      class InvalidOption < StandardError
      end

      DEFAULT_OPTIONS = {
        verbose: false,
        poll:    true,
        tail:    false
      }

      def parse(arguments)
        options = DEFAULT_OPTIONS.dup
        optparse = OptionParser.new do |opts|
          opts.banner = <<-BANNER.gsub(/^\s{4}/, '')
            Karma hotspot status
            Usage: yourkarma [options]
            Example: yourkarma --verbose
          BANNER

          opts.on('-u', '--url=URL', "Karma hotspot URL") do |url|
            options[:url] = url
          end
          opts.on('-t', '--timeout=TIMEOUT', "Time to wait for HTTP response", Float) do |timeout|
            options[:timeout] = timeout
          end
          opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
            options[:verbose] = true
          end
          opts.on('-c', '--count=COUNT', 'Poll COUNT times', Integer) do |c|
            options[:iterations] = c
          end
          opts.on('-p', '--[no-]poll', 'Continually poll') do |p|
            options[:poll] = p
            options[:iterations] = 1 unless p
          end
          opts.on('--[no-]tail', 'Tail log') do |t|
            options[:tail] = t
          end
          opts.on('-h', '--help', 'Display this screen') do
            raise InvalidOption, opts
          end
        end

        optparse.parse!(arguments)

        options
      rescue OptionParser::InvalidOption, OptionParser::MissingArgument
        raise InvalidOption, optparse
      end
    end
  end
end
