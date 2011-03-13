require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'netaddr'

class MobileIP
  def softbank
    base("http://creation.mb.softbank.jp/web/web_ip.html") do |doc|
      records = []
      (doc/"tr").each do |tr|
        (tr/"td[@bgcolor=\"#eeeeee\"]").each do |td|
          # rec << td.inner_html.strip
          records << td.inner_html.sub(/&nbsp;&nbsp;/,'')
        end
      end
      records
    end
  end

  def docomo
    base("http://www.nttdocomo.co.jp/service/imode/make/content/ip/") do |doc|
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
    end
  end

  def au
    base("http://www.au.kddi.com/ezfactory/tec/spec/ezsava_ip.html") do |doc|
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
    end
  end

  def base(url,&block)
    doc = Hpricot(open(url))
    records = block[doc]
    ret = []
    records.uniq.each {|r|
      a = NetAddr::CIDR.create(r)
      a.enumerate.each {|rr|
        ret << rr if (rr != a.ip && rr != a.last)
      }
    }
    ret
  end
end
