# -*- coding: utf-8 -*-
$: << File.expand_path(File.dirname(__FILE__) + "/../lib")

require "mobile_ip"

describe "モバイル環境のIPを返す" do
  context "softbank" do
    before(:all) do
      @mip = MobileIP.softbank
    end
    subject { @mip }
    it { should have(182).ip_list }
    [
     "123.108.237.1",
     "202.253.96.225",
     "210.146.7.193",
     "123.108.237.225",
     "202.253.96.1",
    ].each do |ip|
      it { should be_have(ip) }
    end
  end

  context "docomo" do
    before(:all) do
      @mip = MobileIP.docomo
    end
    subject { @mip }
    it { should have(4318).ip_list }
    [
     "210.153.84.1",
    ].each do |ip|
      it { should be_have(ip) }
    end
  end

  context "AU" do
    before(:all) do
      @mip = MobileIP.au
    end
    subject { @mip }
    it { should have(2388).ip_list }
    [
     "210.230.128.225"
    ].each do |ip|
      it { should  be_have(ip) }
    end
  end
end
