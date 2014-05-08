require "spec_helper"

describe "CLI", ".new" do
  let(:options) { { verbose: true } }
  subject { YourKarma::CLI.new options }
  its(:options) { should eq options }
end

describe "CLI", ".run" do
  it "should parse command line arguments, instantiate CLI instance and run it" do
    io              = double(:io)
    arguments       = double(:arguments)
    options         = {}
    argument_parser = double(:argument_parser, parse: options )
    exit_code       = double(:exit_code)
    cli             = double(:cli, run: exit_code)
    YourKarma::CLI::ArgumentParser.stub(:new) { argument_parser }
    YourKarma::CLI.stub(:new) { cli }
    YourKarma::CLI.run io, arguments
    expect(cli).to have_received(:run).with { { io: io } }
  end
end

describe "CLI", "#run" do
  it "should fetch status from device, benchmark speed and report" do
    client      = double(:client, get: {})
    device      = double(:device)
    benchmark   = double(:benchmark)
    benchmarker = double(:benchmarker, benchmark: benchmark)
    exit_code   = double(:exit_code)
    reporter    = double(:reporter, report_on: exit_code)
    YourKarma::Client.stub(:new)        { client }
    YourKarma::Device.stub(:new)        { device }
    YourKarma::Benchmarker.stub(:new)   { benchmarker }
    YourKarma::CLI::Reporter.stub(:new) { reporter }
    cli = YourKarma::CLI.new
    response = cli.run
    expect(reporter).to have_received(:report_on).with(device, benchmark)
    expect(response).to eq(exit_code)
  end
end
