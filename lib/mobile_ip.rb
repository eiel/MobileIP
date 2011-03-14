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

  attr_reader :ip_list

  def initialize(name,url,&block)
    @name = name
    doc = Hpricot(open(url))
    records = block[doc]
    @ip_list = []
    records.uniq.each {|r|
      a = NetAddr::CIDR.create(r)
      a.enumerate.each {|rr|
        @ip_list << rr if (rr != a.ip && rr != a.last)
      }
    }
  end
end
