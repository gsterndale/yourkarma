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
      reporter  = Reporter.new(options)
      attrs     = Client.new(options).get
      device    = Device.new(attrs)
      benchmark = Benchmarker.new(options).benchmark
      reporter.report_on(device, benchmark)
    rescue Client::ConnectionError => e
      reporter.report_connectivity_failure e.message
    rescue Benchmarker::ConnectionError 
      reporter.report_benchmark_failure_on(device)
    end

    class Reporter
      DEFAULT_OPTIONS = {
        io: STDOUT
      }
      attr_accessor :options

      def initialize(options = {})
        self.options = DEFAULT_OPTIONS.merge(options)
      end

      def report_on(device, benchmark)
        write "Connected to '#{device.ssid}' and online!"
        if options[:verbose]
          ceil = (benchmark * 10).ceil / 10.0
          write "Benchmark took less than #{ceil} seconds."
        end
        0
      end

      def report_connectivity_failure(message)
        write "Not connected to a Karma hotspot."
        write message if options[:verbose]
        1
      end

      def report_benchmark_failure_on(device)
        if device.valid_ipaddress?
          write "Connected to '#{device.ssid}' and online, but the tubes are slow!"
        else
          write "Connected to '#{device.ssid}' and acquiring IP address."
        end
        1
      end

      private

      def write(string)
        options[:io].puts string
      end
    end

    class ArgumentParser
      class InvalidOption < StandardError
      end

      DEFAULT_OPTIONS = {
        verbose: false
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

# require 'json'
# require 'uri'
# require 'net/http'
# require 'timeout'
# require 'benchmark'
# require 'pp'
# 
# uri = URI('http://hotspot.yourkarma.com/api/status.json')
# 
# VERBOSE      = true
# VERY_VERBOSE = false
# TIMEOUT      = 10
# 
# def failure(message, exception, context = nil)
#   if VERBOSE
#     puts exception.class if VERY_VERBOSE
#     puts exception
#     puts context if context && VERY_VERBOSE
#   end
#   puts message
#   exit 1
# end
# 
# HTTP_ERRORS = [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
#   Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
#   SocketError]
# 
# begin
#   response = nil
#   Timeout::timeout(TIMEOUT) do
#     response = Net::HTTP.get_response(uri)
#   end
#   parsed = JSON::load(response.body)
# rescue Timeout::Error => e
#   failure "Request to Karma hotspot timed out.", e
# rescue *HTTP_ERRORS => e
#   failure "Not connected to a Karma hotspot.", e
# rescue JSON::ParserError
#   failure "Unexpected response from #{uri}.", e, parsed
# end
# 
# begin
#   message = "Network not connected."
# 
#   device = parsed.fetch "device"
#   wifi   = device.fetch "wifiinterface"
#   ssid   = wifi.fetch "ssid"
# 
#   message = "Unable to determine battery status."
# 
#   charging  = device.fetch "charging"
#   battery   = device.fetch "batterypower"
#   print "Battery #{battery}%. "
#   puts charging ? "Charging." : "Not charging."
# 
#   message = "Connected to '#{ssid}', but WAN IP address is not assigned."
# 
#   wan        = device.fetch "waninterface"
#   ip_address = wan.fetch "ipaddress"
# rescue KeyError => e
#   failure message, e, parsed
# end
# 
# begin
#   benchmark = nil
#   Timeout::timeout(TIMEOUT) do
#     benchmark = Benchmark.realtime do
#       Net::HTTP.get_response(URI('https://www.google.com'))
#     end
#   end
#   benchmark = (benchmark * 10).ceil / 10.0
# rescue TimeoutError => e
#   failure "Connected to '#{ssid}' and online, but the tubes are slow!", e, parsed
# rescue *HTTP_ERRORS => e
#   failure "Connected to '#{ssid}' and WAN IP address has be assigned, but request to Google failed.", e, parsed
# end
# 
# puts "Connected to '#{ssid}' and online!"
# puts "Request to Google took less than #{benchmark} seconds." if VERBOSE
