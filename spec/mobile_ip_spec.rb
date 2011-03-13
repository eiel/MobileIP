# -*- coding: utf-8 -*-
$: << File.expand_path(File.dirname(__FILE__) + "/../lib")

require "mobile_ip"

describe "モバイル環境のIPを返す" do
  before(:all) do
    @ip = mobile_ip
  end

  subject { @ip }
  it { should be_an_instance_of(Hash) }

  context "softbank" do
    subject { @ip[:softbank] }
    it { should have(182).items }
  end

  context "docomo" do
    subject { @ip[:docomo] }
    it { should have(4318).items }
  end

  context "AU" do
    subject { @ip[:au]}
    it { should have(2388).items }
  end
end
