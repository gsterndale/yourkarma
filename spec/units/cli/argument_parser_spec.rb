require "spec_helper"

describe "YourKarma::CLI::ArgumentParser" do
  subject(:cli) { YourKarma::CLI::ArgumentParser.new }

  describe "#parse" do
    let(:arguments) { ["--url", "http://example.com"] }
    subject { cli.parse(arguments) }
    its([:verbose]) { should be false }
    its([:url])     { should eq "http://example.com"}

    context "help argument" do
      let(:arguments) { ["--help"] }
      it "should raise InvalidOption exception" do
        expect(-> { subject }).to raise_error YourKarma::CLI::ArgumentParser::InvalidOption
      end
    end

    context "invalid arguments" do
      let(:arguments) { ["--WRONG"] }
      it "should raise InvalidOption exception" do
        expect(-> { subject }).to raise_error YourKarma::CLI::ArgumentParser::InvalidOption
      end
    end
  end
end
