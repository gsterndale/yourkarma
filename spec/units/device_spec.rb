require "spec_helper"

describe WhatKarma::Device do
  let(:attrs) { { 'ssid' => "My Karma", 'ipaddress' => "127.0.0.1" } }
  subject { WhatKarma::Device.new attrs }

  its(:ssid) { should eq "My Karma" }
  its(:ipaddress) { should eq "127.0.0.1" }

end

describe WhatKarma::Device, "#valid_ipaddress?" do
  context "with a real IP address" do
    subject { WhatKarma::Device.new 'ipaddress' => "127.0.0.1" }
    its(:valid_ipaddress?) { should be_true }
  end
  context "with a real IP address" do
    subject { WhatKarma::Device.new 'ipaddress' => "N/A" }
    its(:valid_ipaddress?) { should be_false }
  end
end
