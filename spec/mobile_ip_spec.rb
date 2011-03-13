# -*- coding: utf-8 -*-
$: << File.expand_path(File.dirname(__FILE__) + "/../lib")

require "mobile_ip"

describe "モバイル環境のIPを返す" do
  before(:all) do
    @mip = MobileIP.new
  end

  context "softbank" do
    subject { @mip.softbank }
    it { should have(182).items }
  end

  context "docomo" do
    subject { @mip.docomo }
    it { should have(4318).items }
  end

  context "AU" do
    subject { @mip.au}
    it { should have(2388).items }
  end
end
