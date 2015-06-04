cities =  [
  {"name"=>"Las Vegas", "detail"=>"Nevada", "photo"=>"d|v1378747548/las_vegas_xzqlvz.jpg"},
  {"name"=>"New York", "detail"=>"New York", "photo"=>"d|v1393292178/new_york_iriwla.jpg"},
  {"name"=>"San Diego", "detail"=>"California", "photo"=>"d|v1378747548/san_diego_oj3a5w.jpg"},
  {"name"=>"San Francisco", "detail"=>"California", "photo"=>"d|v1378747548/san_francisco_hv2bsc.jpg"},
  {"name"=>"Santa Barbara", "detail"=>"California", "photo"=>"d|v1393292171/santa_barbara_lqln3n.jpg"},
  {"name"=>"Philadelphia", "detail"=>"Pennsylvania", active: false},
  {"name"=>"Long Beach", "detail"=>"California", active: false},
  {"name"=>"Newport Beach", "detail"=>"California", "photo"=>"d|v1416615229/newportbeach_bwwmrq.jpg"},
  {"name"=>"Elkhart Lake", "detail"=>"Wisconsin", "photo"=>"d|v1418237673/elkheart_tplhzq.jpg"},
  {"name"=>"COCHON 555 US TOUR", "detail"=>"Nationwide", "photo"=>"d|v1417972995/cochon_hr8ixy.png"},
  {"name"=>"Orange County", "detail"=>"California", "photo"=>"d|v1419883807/orange_country_pgbmsg.jpg"}
]

cities.each do |city|

	region = Region.new(name: city['name'], detail: city['detail'], photo: city['photo'])
	region.active = false if city[:active] == false
	region.save

end