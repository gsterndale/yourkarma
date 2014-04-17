require "spec_helper"

describe "CLI::Reporter" do
  let(:arguments) { { verbose: true } }
  let(:reporter)  { WhatKarma::CLI::Reporter.new arguments }

  describe "#options" do
    subject { reporter.options }

    its([:io]) { should eq STDOUT }
    its([:verbose]) { should be true }
  end
end

describe "CLI::Reporter", "#report_on" do
  let(:io)        { StringIO.new }
  let(:device)    { WhatKarma::Device.new ssid: "My Karma" }
  let(:benchmark) { 123.45 }
  let(:reporter)  { WhatKarma::CLI::Reporter.new({ io: io, verbose: true }) }
  let!(:status)   { reporter.report_on(device, benchmark) }
  subject { status }

  it { should be 0 }

  describe "io" do
    subject { io.string }
    it { should match "My Karma" }
    it { should match /123.5/ }
  end
end

describe "CLI::Reporter", "#report_connectivity_failure" do
  let(:io)        { StringIO.new }
  let(:reporter)  { WhatKarma::CLI::Reporter.new({ io: io }) }
  let(:message)   { "Whoops" }
  let!(:status)   { reporter.report_connectivity_failure(message) }
  subject { status }

  it { should be 1 }

  describe "io" do
    subject { io.string }
    it { should match "Not connected" }
  end
end

describe "CLI::Reporter", "#report_benchmark_failure_on" do
  let(:io)        { StringIO.new }
  let(:device)    { WhatKarma::Device.new ssid: "My Karma", ipaddress: "192.168.1.1" }
  let(:reporter)  { WhatKarma::CLI::Reporter.new({ io: io }) }
  let!(:status)   { reporter.report_benchmark_failure_on(device) }
  subject { status }

  it { should be 1 }

  describe "io" do
    subject { io.string }
    it { should match "My Karma" }
    it { should match "slow" }
  end
end
