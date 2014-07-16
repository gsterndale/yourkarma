require "spec_helper"

describe YourKarma::Device do
  let(:attrs) { { 'ssid' => "My Karma", 'ipaddress' => "127.0.0.1" } }
  subject { YourKarma::Device.new attrs }

  its(:ssid) { should eq "My Karma" }
  its(:ipaddress) { should eq "127.0.0.1" }

end

describe YourKarma::Device, "#valid_ipaddress?" do
  context "with a real IP address" do
    subject { YourKarma::Device.new 'ipaddress' => "127.0.0.1" }
    its(:valid_ipaddress?) { should be_truthy }
  end
  context "with a real IP address" do
    subject { YourKarma::Device.new 'ipaddress' => "N/A" }
    its(:valid_ipaddress?) { should be_falsey }
  end
end
