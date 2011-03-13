#require 'rubygems'

require 'hpricot'
require 'open-uri'
require 'netaddr'

def mobile_ip()
  ret = {}
  doc = Hpricot(open("http://creation.mb.softbank.jp/web/web_ip.html"))
  records = []
  (doc/"tr").each do |tr|
    (tr/"td[@bgcolor=\"#eeeeee\"]").each do |td|
      # rec << td.inner_html.strip
      records << td.inner_html.sub(/&nbsp;&nbsp;/,'') 
    end
  end
  ret[:softbank] = []
  records.uniq.each {|r|
    a = NetAddr::CIDR.create(r)
    a.enumerate.each {|rr|
      ret[:softbank] << rr if (rr != a.ip && rr != a.last)
    }
  }

  doc = Hpricot(open("http://www.nttdocomo.co.jp/service/imode/make/content/ip/"))
  records = []
  (doc/"ul[@class=\"normal txt\"]").each do |ul|
    (ul/"li").each do |li|
      # rec << td.inner_html.strip
      # pp li.inner_html.to_s
      /^\d+\.\d+\.\d+\.\d+\/\d+/ =~ li.inner_html.to_s
      records << $&
    end
  end
  ret[:docomo] = []
  #pp records.uniq
  records.uniq.each {|r|
    a = NetAddr::CIDR.create(r)
    a.enumerate.each {|rr|
      # pp rr
      ret[:docomo] << rr if (rr != a.ip && rr != a.last)
    }
  }

  doc = Hpricot(open("http://www.au.kddi.com/ezfactory/tec/spec/ezsava_ip.html"))
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

  ret[:au] = []
  #pp records.uniq
  records.uniq.each {|r|
    a = NetAddr::CIDR.create(r)
    a.enumerate.each {|rr|
      ret[:au] << rr if (rr != a.ip && rr != a.last)
    }
  }
  ret
end
