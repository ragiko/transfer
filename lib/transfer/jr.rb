require "open-uri"
require "uri"
require "pp"
require "nokogiri"

module Transfer
  class Jr
    class << self
      # param: type_str "到着" or "出発"
      def search(from, to, y, m, d, hour, min, type_str)
        ### 調査1
        # http://transit.loco.yahoo.co.jp/search/result?
        # flatlon=
        # &from=%E5%B2%90%E9%98%9C
        # &tlatlon=&
        # to=%E5%90%8D%E5%8F%A4%E5%B1%8B
        # &via=&via=&via=
        # &y=2015 # 年
        # &m=06 # 月
        # &d=14 # 日
        # &hh=23 # 時間
        # &m2=0
        # &m1=3 # 30分 (m1 m2)
        # &type=1 # (type: 1 出発, type 4: 到着)
        # &ticket=normal (ic: ic料金 or normal: 現金
        # &al=1
        # &shin=1
        # &ex=1
        # &hb=1
        # &lb=1
        # &sr=1
        # &s=0
        # &expkind=1
        # &ws=2
        # &kw=%E5%90%8D%E5%8F%A4%E5%B1%8B # 到着駅

        ### 調査2 出発時
        # http://transit.loco.yahoo.co.jp/search/result?
        # flatlon=
        # &from=岐阜
        # &tlatlon=
        # &to=名古屋
        # &via=&via=&via=
        # &y=2015
        # &m=06
        # &d=14
        # &hh=18
        # &m2=1
        # &m1=3
        # &type=1
        # &ticket=normal
        # &al=1
        # &shin=1
        # &ex=1
        # &hb=1
        # &lb=1
        # &sr=1
        # &s=0
        # &expkind=1
        # &ws=2
        # &kw=名古屋

        # url = self.req_url(from="岐阜", to="名古屋", 2015, 6, 14, hour=10, min=00, "出発")
        url = self.req_url(from, to, y, m, d, hour, min, type_str)

        begin
          html = open(URI.escape(url))
          doc = Nokogiri::HTML(html)
        rescue => e
        end

        routes = []
        doc.css('#srline div[id*="route0"]').each do |route|
          time_list = route.css("li.time").text.scan(/\d{2}:\d{2}/)
          min = route.css("li.time").text.match(/(\d*?分)/)[1]
          fare = route.css("li.fare").text.match(/現金優先：(.*?円)/)[1]

          route_details = {}
          route.css(".routeDetail").each do |route_detail|
            stations = []
            route_detail.css(".station").each do |station|
              time = station.css("ul.time").text
              name = station.css("dl > dt > a").text

              stations << {time: time, name: name}
            end

            between = route_detail.css(".btnStopNum").text
            transport = route_detail.css("li.transport > div").text.delete("\n[train]")
            route_details = {
                between: between,
                transport: transport,
                stations: stations
            }
          end

          routes << {
              time_list: time_list,
              min: min,
              fare: fare,
              route_details: route_details
          }
        end

        routes
      end

      def req_url(from, to, y, m, d, hour, min, type_str)
          _m = format("%02d", m)
          _min = format("%02d", min)
          m1 = _min.to_s[0]
          m2 = _min.to_s[1]
          type = type_str == "出発" ? 1 : 4 # 4 is 到着
          return "http://transit.loco.yahoo.co.jp/search/result?\
flatlon=\
&from=#{from}\
&tlatlon=\
&to=#{to}\
&via=&via=&via=\
&y=#{y}\
&m=#{_m}\
&d=#{d}\
&hh=#{hour}\
&m1=#{m1}&m2=#{m2}\
&type=#{type}\
&ticket=normal\
&al=1\
&shin=1&ex=1&hb=1&lb=1&sr=1&s=0&expkind=1&ws=2\
&kw=#{to}"
        end
    end
  end
end