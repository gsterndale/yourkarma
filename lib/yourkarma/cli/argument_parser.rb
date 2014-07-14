require 'optparse'

module YourKarma
  class CLI
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
