require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'netaddr'

class MobileIP
  VENDERS = {
    :softbank =>
    {
      :name => "Softbank",
      :url => "http://creation.mb.softbank.jp/web/web_ip.html",
      :get_proc => proc { |doc|
        records = []
        (doc/"tr").each do |tr|
          (tr/"td[@bgcolor=\"#eeeeee\"]").each do |td|
            records << td.inner_html.sub(/&nbsp;&nbsp;/,'')
          end
        end
        records
      },
    },
    :docomo =>
    {
      :name => "DoCoMo",
      :url => "http://www.nttdocomo.co.jp/service/imode/make/content/ip/",
      :get_proc => proc { |doc|
        records = []
        (doc/"ul[@class=\"normal txt\"]").each do |ul|
          (ul/"li").each do |li|
            # rec << td.inner_html.strip
            # pp li.inner_html.to_s
            /^\d+\.\d+\.\d+\.\d+\/\d+/ =~ li.inner_html.to_s
            records << $&
          end
        end
        records
      },
    },
    :au => {
      :name => "AU",
      :url => "http://www.au.kddi.com/ezfactory/tec/spec/ezsava_ip.html",
      :get_proc => proc {|doc|
        records = []
        ip = ""
        (doc/"tr[@bgcolor=\"#ffffff\"]").each do |ul|
          (ul/"div.TableText").each do |li|
            # rec << td.inner_html.strip
            #pp li.inner_html.to_s
            #ip = ""
            if /^\d+\.\d+\.\d+\.\d+/ =~ li.inner_html.to_s
              ip = $&
              #pp ip
            end
            if /^\/\d+/ =~ li.inner_html.to_s
              ip = ip + $&
              #pp ip
            end
            if /^\d+\.\d+\.\d+\.\d+\/\d+/ =~ ip.to_s
              records << $&
              ip = ""
            end
          end
        end
        records
      }
    },
  }

  class << self
    VENDERS.each do |key,value|
      define_method(key,
                    proc {
                      self.new(value[:name],
 value[:url],
                               &value[:get_proc])
                    })
    end
  end

  def self.where_is(ip)
    VENDERS.each do |vender,value|
      return vender if self.send(vender).have? ip
    end
    nil
  end

  attr_reader :ip_list

  def initialize(name,url,&get_addrs)
    @name = name
    doc = Hpricot(open(url))
    addrs = get_addrs[doc]
    @ip_list = []
    addrs.uniq.each {|r|
      a = NetAddr::CIDR.create(r)
      a.enumerate.each {|rr|
        @ip_list << rr if (rr != a.ip && rr != a.last)
      }
    }
  end

  def have?(ip)
    @ip_list.include?(ip)
  end
end
