require "spec_helper"

describe "CLI", ".new" do
  let(:options) { { verbose: true } }
  subject { WhatKarma::CLI.new options }
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
    WhatKarma::CLI::ArgumentParser.stub(:new) { argument_parser }
    WhatKarma::CLI.stub(:new) { cli }
    WhatKarma::CLI.run io, arguments
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
    WhatKarma::Client.stub(:new)        { client }
    WhatKarma::Device.stub(:new)        { device }
    WhatKarma::Benchmarker.stub(:new)   { benchmarker }
    WhatKarma::CLI::Reporter.stub(:new) { reporter }
    cli = WhatKarma::CLI.new
    response = cli.run
    expect(reporter).to have_received(:report_on).with(device, benchmark)
    expect(response).to eq(exit_code)
  end
end
