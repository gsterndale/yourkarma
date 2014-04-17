require 'uri'
require 'timeout'
require 'net/http'
require 'benchmark'

module WhatKarma
  class Benchmarker
    class ConnectionError < StandardError; end

    HTTP_ERRORS = [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
                   Errno::ETIMEDOUT, EOFError, Net::HTTPBadResponse,
                   Net::HTTPHeaderSyntaxError, Net::ProtocolError, SocketError]

    DEFAULT_OPTIONS = {
      timeout:   10,
      benchmark: 'http://yourkarma.com/dashboard'
    }

    attr_accessor :options

    def initialize(options = {})
      self.options = DEFAULT_OPTIONS.merge(options)
    end

    def benchmark
      uri = URI(options[:benchmark])
      Timeout::timeout(options[:timeout]) do
        return Benchmark.realtime do
          Net::HTTP.get_response(uri)
        end
      end
    rescue *HTTP_ERRORS => e
      raise ConnectionError
    end
  end
end
