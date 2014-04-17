require 'spec_helper'

describe WhatKarma::Client do
  describe "#options" do
    let(:client)  { WhatKarma::Client.new }
    subject       { client.options } 
    its([:url])  { should match "yourkarma.com" }
  end

  describe "#get" do
    let(:client)    { WhatKarma::Client.new(url: "example.com") }
    let(:response)  { double :response, body: '{"device": {"foo": "bar"}}' }
    subject         { client.get }
    before do
      Net::HTTP.stub(:get_response) { response }
    end

    its(['foo']) { should eq 'bar' }

    it "makes request to url" do
      subject
      uri = URI('example.com')
      expect(Net::HTTP).to have_received(:get_response).with(uri)
    end

    context "timing out" do
      before do
        Net::HTTP.stub(:get_response) { raise Timeout::Error }
      end

      it "raises ConnectionError" do
        expect(-> { subject }).to raise_error WhatKarma::Client::ConnectionError
      end
    end

    context "with an HTTP error" do
      before do
        Net::HTTP.stub(:get_response) { raise SocketError }
      end

      it "raises ConnectionError" do
        expect(-> { subject }).to raise_error WhatKarma::Client::ConnectionError
      end
    end

    context "with bad JSON" do
      let(:response)  { double :response, body: '{ WRONG }' }

      it "raises BadResponseError" do
        expect(-> { subject }).to raise_error WhatKarma::Client::BadResponseError
      end
    end
  end
end
