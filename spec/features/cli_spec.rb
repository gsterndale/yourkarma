require 'spec_helper'
require 'webmock/rspec'

describe "CLI", :vcr do
  let(:io)   { StringIO.new }
  let(:timeout) { 0.01 }
  let(:args) { ['--timeout', timeout.to_s, '--verbose', '--no-poll'] }
  let(:cli)  { YourKarma::CLI.run(io, args) }

  describe "output" do
    # | Connect | Speed | Battery | Charging | Bandwidth |
    # +---------+-------+---------+----------+-----------+
    # |   -=≡   | ==>-- | [###  } |  =D----  |    1.3 GB |
    let(:string) do
      cli
      io.string
    end
    let(:header) do
      string.split("\n")
        .first
        .split(/\s*\|\s*/)[1..-1]
    end
    let(:rows) do
      string.split("\n")[2..-1].map do |row|
        Hash[
          row
          .split(/\s*\|\s*/)[1..-1]
          .each_with_index
          .map{|cell, i| [header[i], cell.strip] }
        ]
      end
    end
    subject { rows.first }

    context "connected to a hotspot and the internet", vcr: {cassette_name: "online"} do
      its(["Connect"]) { should eq "-=≡" }

      context "with a slow connection" do
        before do
          allow(Benchmark).to receive_messages(realtime: timeout)
        end
        its(["Speed"]) { should eq "(ಠ_ಠ)" }
      end

      context "with a fast connection" do
        before do
          allow(Benchmark).to receive_messages(realtime: timeout / 100.0 )
        end
        its(["Speed"]) { should eq "(⌐■_■)" }
      end

      context "full battery power", vcr: {cassette_name: "full_battery"} do
        its(["Battery"]) { should eq "[#####}" }
      end

      context "low battery power", vcr: {cassette_name: "low_battery"} do
        its(["Battery"]) { should eq "[#    }" }
      end

      context "charging", vcr: {cassette_name: "charging"} do
        its(["Charging"])  { should eq "=D----" }
      end

      context "not charging", vcr: {cassette_name: "not_charging"} do
        its(["Charging"])  { should eq "X" }
      end
    end

    context "connected to a hotspot and the internet, but requests timeout", vcr: {cassette_name: "online_timeout"} do
      before do
        stub_request(:any, /.*yourkarma.com\/dashboard.*/).to_raise(Timeout::Error.new "Fail")
      end
      its(["Connect"]) { should eq "-=" }
      its(["Speed"])   { should eq ":(" }
    end

    context "connected to a hotspot, but not to the internet", vcr: {cassette_name: "no_wan"} do
      before do
        stub_request(:any, /.*yourkarma.com\/dashboard.*/).to_raise(Timeout::Error.new "Fail")
      end

      its(["Connect"])   { should eq "-" }
      its(["Speed"])     { should eq ":X" }
    end

    context "not connected to a hotspot", vcr: {cassette_name: "offline"} do
      before do
        stub_request(:any, /.*yourkarma.com.*/).to_raise(Timeout::Error.new "Fail")
      end
      its(["Connect"])   { should eq "" }
      its(["Speed"])     { should eq ":X" }
      its(["Battery"])   { should eq "[?????}" }
      its(["Charging"])  { should eq "?" }
    end

    context "polling", vcr: { allow_playback_repeats: true, cassette_name: "online"} do
      subject { rows.size }
      let(:args) { ['--timeout', timeout.to_s, '--verbose', '--count', '2', '--no-tail'] }
      it { is_expected.to be 1 }

      context "tailing" do
        let(:args) { ['--timeout', timeout.to_s, '--verbose', '--count', '2', '--tail'] }
        it { is_expected.to be 2 }
      end
    end
  end

  describe "status code" do
    subject { cli }

    context "connected to a hotspot and the internet", vcr: {cassette_name: "online"} do
      it { is_expected.to be 0 }

      context "with a slow connection" do
        before do
          allow(Benchmark).to receive_messages(realtime: timeout)
        end
        it { is_expected.to be 0 }
      end
    end

    context "connected to a hotspot and the internet, but requests timeout", vcr: {cassette_name: "online_timeout"} do
      before do
        stub_request(:any, /.*yourkarma.com\/dashboard.*/).to_raise(Timeout::Error.new "Fail")
      end
      it { is_expected.to be 3 }
    end

    context "connected to a hotspot, but not to the internet", vcr: {cassette_name: "no_wan"} do
      before do
        stub_request(:any, /.*yourkarma.com\/dashboard.*/).to_raise(Timeout::Error.new "Fail")
      end
      it { is_expected.to be 3 }
    end

    context "not connected to a hotspot", vcr: {cassette_name: "offline"} do
      before do
        stub_request(:any, /.*yourkarma.com.*/).to_raise(Timeout::Error.new "Fail")
      end
      it { is_expected.to be 3 }
    end
  end
end
