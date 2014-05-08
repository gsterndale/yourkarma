require 'spec_helper'
require 'webmock/rspec'

describe "CLI", :vcr do
  let(:io)   { StringIO.new }
  let(:args) { ['--timeout', '10', '--verbose'] }
  let(:cli)  { YourKarma::CLI.run(io, args) }

  describe "output" do
    subject do
      cli
      io.string
    end

    context "connected to a hotspot" do
      it { should match /connected/i }
    end

    context "connected to the internet" do
      it { should match "online" }
      it { should_not match /slow/i }
    end

    context "connected to the internet with a slow connection" do
      before do
        stub_request(:any, /.*yourkarma.com\/dashboard.*/).to_raise(Timeout::Error.new "Fail")
      end
      it { should match /slow/i }
    end

    context "connected to a hotspot without an assigned WAN IP address" do
      before do
        stub_request(:any, /.*yourkarma.com\/dashboard.*/).to_raise(Timeout::Error.new "Fail")
      end
      it { should match /acquiring IP address/i }
      it { should_not match "Fail" }
    end

    context "not connected to a hotspot" do
      before do
        stub_request(:any, /.*yourkarma.com.*/).to_raise(Timeout::Error.new "Fail")
      end
      it { should match /Not connected/i }
      it { should match "Fail" }
    end
  end

  describe "status code" do
    subject { cli }

    context "connected to the internet" do
      it { should be 0 }
    end

    context "connected to the internet with a slow connection" do
      before do
        stub_request(:any, /.*yourkarma.com\/dashboard.*/).to_raise(Timeout::Error.new "Fail")
      end
      it { should be 1 }
    end

    context "connected to a hotspot without an assigned WAN IP address" do
      before do
        stub_request(:any, /.*yourkarma.com\/dashboard.*/).to_raise(Timeout::Error.new "Fail")
      end
      it { should be 1 }
    end

    context "not connected to a hotspot" do
      before do
        stub_request(:any, /.*yourkarma.com.*/).to_raise(Timeout::Error.new "Fail")
      end
      it { should be 1 }
    end
  end
end

