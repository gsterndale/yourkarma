require "spec_helper"

describe "CLI", ".new" do
  let(:options) { { verbose: true } }
  subject { YourKarma::CLI.new options }
  its(:options) { should eq options }
end

describe "CLI", ".run" do
  it "should parse command line arguments, instantiate CLI instance and run it" do
    io              = double :io
    arguments       = double :arguments
    options         = {}
    argument_parser = instance_double "YourKarma::CLI::ArgumentParser", parse: options
    exit_code       = 0
    cli             = instance_double "YourKarma::CLI", run: exit_code
    allow(YourKarma::CLI::ArgumentParser).to receive_messages(new: argument_parser)
    allow(YourKarma::CLI).to receive_messages(new: cli)
    YourKarma::CLI.run io, arguments
    expect(cli).to have_received(:run)
  end
end

describe "CLI", "#run" do
  let(:iterations) { 3 }
  let(:cli)        { YourKarma::CLI.new iterations: iterations }
  let(:response)   { cli.run }
  let(:benchmark)  { 0.987 }
  let(:exit_code)  { 0 }
  let(:client)     { instance_double "YourKarma::Client", get: {} }
  let(:device)     { instance_double "YourKarma::Device" }
  let(:benchmarker){ instance_double "YourKarma::Benchmarker", benchmark: benchmark }
  let(:reporter) do
    instance_double "YourKarma::CLI::Reporter",
      report_header:   nil,
      report_progress: nil,
      report_on:       exit_code,
      report_quit:     exit_code
  end

  before do
    allow(YourKarma::Client).to         receive_messages(new: client )
    allow(YourKarma::Device).to         receive_messages(new: device )
    allow(YourKarma::Benchmarker).to    receive_messages(new: benchmarker )
    allow(YourKarma::CLI::Reporter).to  receive_messages(new: reporter )
    response
  end

  describe "#reporter" do
    subject { reporter }
    it { is_expected.to have_received(:report_header).once }
    it { is_expected.to have_received(:report_progress).exactly(iterations).times }
    it { is_expected.to have_received(:report_on).with(device, benchmark).exactly(iterations).times }
    it { is_expected.to have_received(:report_quit).with(exit_code).once }
  end

  it "returns last exit status code" do
    expect(response).to eq(exit_code)
  end

  context "exiting upon success" do
    let(:cli) { YourKarma::CLI.new iterations: iterations, exit_on_success: true }
    let(:reporter) do
      instance_double(
        "YourKarma::CLI::Reporter",
        report_header:   nil,
        report_progress: nil,
        report_quit:     exit_code
      ).tap do |rptr|
        allow(rptr).to receive(:report_on).and_return(1, 0, 1)
      end
    end

    it "polls until there's a successful exit status code (0)" do
      expect(reporter).to have_received(:report_progress).exactly(2).times
    end

    it "returns last exit status code" do
      expect(response).to eq 0
    end
  end
end
