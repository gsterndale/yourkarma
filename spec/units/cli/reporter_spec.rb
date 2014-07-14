require "spec_helper"

describe "CLI::Reporter" do
  let(:arguments) { { verbose: true } }
  let(:reporter)  { YourKarma::CLI::Reporter.new arguments }

  describe "#options" do
    subject { reporter.options }

    its([:io]) { should eq STDOUT }
    its([:verbose]) { should be true }
  end
end

describe "CLI::Reporter", "#report_on" do
  let(:io)        { StringIO.new }
  let(:device)    { YourKarma::Device.new batterypower: 30 }
  let(:benchmark) { 0.123 }
  let(:reporter)  { YourKarma::CLI::Reporter.new({ io: io, verbose: true }) }
  let(:status)    { reporter.report_on(device, benchmark) }
  before do
    status
  end

  describe "status" do
    subject { status }
    it { should be 0 }

    context "without benchmark" do
      let(:benchmark) { nil }
      it { should be 3 }
    end
  end

  describe "io" do
    subject { io.string }
    it { should include "-=≡" }
    it { should include "(⌐■_■)" }
    it { should include "[#    }" }
    it { should include "X" }
  end
end

describe "CLI::Reporter", "#report_progress" do
  let(:io)        { StringIO.new }
  let(:reporter)  { YourKarma::CLI::Reporter.new({ io: io }) }
  subject { io.string }

  before do
    reporter.report_progress
  end

  it { should_not include "." }

  context "after reporting on" do
    before do
      reporter.report_on(nil, nil)
      reporter.report_progress
    end
    it { should include "." }
  end
end

describe "CLI::Reporter", "#report_error" do
  let(:io)        { StringIO.new }
  let(:reporter)  { YourKarma::CLI::Reporter.new({ io: io }) }
  subject { io.string }

  before do
    reporter.report_error
  end

  it { should_not include "*" }

  context "after reporting on" do
    before do
      reporter.report_on(nil, nil)
      reporter.report_error
    end
    it { should include "*" }
  end
end

describe "CLI::Reporter", "#report_quit" do
  let(:io)        { StringIO.new }
  let(:reporter)  { YourKarma::CLI::Reporter.new({ io: io }) }
  let(:code)      { 123 }
  let(:status)    { reporter.report_quit code }
  subject { status }

  it { should eq code }

  context "nil code" do
    let(:code) { nil }
    it { should eq 1 }
  end
end
