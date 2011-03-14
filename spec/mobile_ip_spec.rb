# -*- coding: utf-8 -*-
$: << File.expand_path(File.dirname(__FILE__) + "/../lib")

require "mobile_ip"

describe "モバイル環境のIPを返す" do
  context "softbank" do
    subject { MobileIP.softbank }
    it { should have(182).ip_list }
  end

  context "docomo" do
    subject { MobileIP.docomo }
    it { should have(4318).ip_list }
  end

  context "AU" do
    subject { MobileIP.au }
    it { should have(2388).ip_list }
  end
end
