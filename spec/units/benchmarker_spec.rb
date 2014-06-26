require 'spec_helper'

describe YourKarma::Benchmarker do

  describe "#options" do
    subject { YourKarma::Benchmarker.new.options }
    its([:timeout])   { should eq 10 }
    its([:benchmark]) { should match "yourkarma.com" }
  end

  describe "#benchmark" do
    let(:benchmarker) { YourKarma::Benchmarker.new(benchmark: "example.com") }
    let(:response)    { double :response }
    subject           { benchmarker.benchmark }
    before do
      Net::HTTP.stub(:get_response) { response }
    end

    it "makes request to url" do
      subject
      uri = URI('example.com')
      expect(Net::HTTP).to have_received(:get_response).with(uri)
    end

    it "returns execution time" do
      Benchmark.stub(:realtime) { 1.2345 }
      subject.should eq 1.2345 / 10.0
    end

    context "timing out" do
      before do
        Timeout.stub(:timeout) { raise Timeout::Error }
      end

      it "raises ConnectionError" do
        expect(-> { subject }).to raise_error YourKarma::Benchmarker::ConnectionError
      end
    end

    context "with an HTTP error" do
      before do
        Net::HTTP.stub(:get_response) { raise SocketError }
      end

      it "raises ConnectionError" do
        expect(-> { subject }).to raise_error YourKarma::Benchmarker::ConnectionError
      end
    end
  end
end
