require 'uri'
require 'timeout'
require 'net/http'

module YourKarma
  class Client
    class ConnectionError < StandardError; end
    class BadResponseError < StandardError; end

    HTTP_ERRORS = [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
                   Errno::ENETUNREACH, Errno::ETIMEDOUT, EOFError,
                   Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
                   Net::ProtocolError, SocketError]

    DEFAULT_OPTIONS = {
      timeout: 10,
      url: "http://hotspot.yourkarma.com/api/status.json",
    }

    attr_accessor :options

    def initialize(options = DEFAULT_OPTIONS)
      self.options = DEFAULT_OPTIONS.merge(options)
    end

    def get
      uri      = URI(options[:url])
      response = nil
      Timeout::timeout(options[:timeout]) do
        response = Net::HTTP.get_response(uri)
      end
      raise ConnectionError unless response.code == '200'
      JSON::load(response.body).fetch("device")
    rescue *HTTP_ERRORS => e
      raise ConnectionError, e.message
    rescue JSON::ParserError => e
      raise BadResponseError, e.message
    end
  end
end

# {
#   "device"=>{
#     "name"=>"IMW-C918W",
#     "swversion"=>"R4855",
#     "hwversion"=>"R06",
#     "uptime"=>"P0Y0M0DT0H14M41S",
#     "batterypower"=>100,
#     "charging"=>false,
#     "waninterface"=>{
#       "macaddress"=>"001E312C42D0",
#       "ipaddress"=>"74.60.178.162",
#       "bsid"=>"00:00:02:06:04:30",
#       "rssi"=>-59,
#       "cinr"=>20,
#       "connectionduration"=>"P0Y0M0DT0H9M54S"
#     },
#     "wifiinterface"=>{
#       "ssid"=>"Karma Wi-Fi",
#       "users"=>2
#     }
#   }
# }
