require 'json'

module WhatKarma
  class Device
    IPADDRESS_PATTERN = /^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$/

    attr_accessor *%i(name swversion hwversion uptime batterypower charging
                     macaddress ipaddress bsid rssi cinr connectionduration
                     ssid users)

    def initialize(attrs = {})
      self.attributes = attrs
    end

    def waninterface=(attrs)
      self.attributes = attrs
    end

    def wifiinterface=(attrs)
      self.attributes = attrs
    end

    def valid_ipaddress?
      self.ipaddress && self.ipaddress.match(IPADDRESS_PATTERN)
    end

    private

    def attributes=(attrs)
      attrs.each_pair do |name, value|
        self.public_send("#{name}=", value)
      end
    end
  end
end
