require 'spec_helper'

describe YourKarma::Client do
  describe "#options" do
    let(:client)  { YourKarma::Client.new }
    subject       { client.options }
    its([:url])  { should match "yourkarma.com" }
  end

  describe "#get" do
    let(:client)      { YourKarma::Client.new(url: "example.com") }
    let(:status_code) { '200' }
    let(:body)        { '{"device": {"foo": "bar"}}' }
    let(:response)    { double :response, body: body, code: status_code }
    subject           { client.get }
    before do
      allow(Net::HTTP).to receive_messages(get_response: response)
    end

    its(['foo']) { should eq 'bar' }

    it "makes request to url" do
      subject
      uri = URI('example.com')
      expect(Net::HTTP).to have_received(:get_response).with(uri)
    end

    context "timing out" do
      before do
        allow(Net::HTTP).to receive(:get_response).and_raise(Timeout::Error)
      end

      it "raises ConnectionError" do
        expect(-> { subject }).to raise_error YourKarma::Client::ConnectionError
      end
    end

    context "with an unsuccessfull HTTP status code" do
      let(:status_code) { '500' }
      it "raises ConnectionError" do
        expect(-> { subject }).to raise_error YourKarma::Client::ConnectionError
      end
    end

    context "with an HTTP error" do
      before do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
      end

      it "raises ConnectionError" do
        expect(-> { subject }).to raise_error YourKarma::Client::ConnectionError
      end
    end

    context "with bad JSON" do
      let(:body) { '{ WRONG }' }
      it "raises BadResponseError" do
        expect(-> { subject }).to raise_error YourKarma::Client::BadResponseError
      end
    end
  end
end
