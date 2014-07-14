require_relative 'client'
require_relative 'device'
require_relative 'benchmarker'
require_relative 'cli/reporter'
require_relative 'cli/argument_parser'

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
  end
end
