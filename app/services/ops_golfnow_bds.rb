class OpsGolfnowBds

	attr_reader :api_url, :username, :password, :user_add, :auto_add, :auto_skip, :courses, :response

	def initialize
		@api_url = 'https://v2.bds.gnsvc.com/'
		@username = 'ItsOnMe_BDS'
		@password = 'LsUvA8czpUPQBK8d'
		@response = nil
		@user_add = []
		@auto_add = []
		@auto_skip = []
		@courses = []
	end

	def fuzzy_match(hsh)
		ary = hsh['name'].split(' ')
		aa = ary.select { |a| !['golf', 'club', 'the', 'of', 'a', 'resort' , 'course' , '-'].include?(a.downcase) }
		aa.each { |aaa| aaa.gsub!("\'s", '')}
		aa.each { |aaa| aaa.gsub!("\'", '' )}
		short_name = "#{aa[0]} #{aa[1]}"
		Merchant.where(state: hsh["stateOrProvince"], affiliate_id: 31).where("name ilike '%#{short_name}%'")
	end

	def match facilities=@courses
		facilities.each do |h|
			name = h['name']
			puts name
			ms = fuzzy_match(h)
			if ms.length > 1
				puts "MATCHED ITEMS #{ms.length.to_s}"
			else
				puts "matched items #{ms.length.to_s}"
			end
			ms.each { |m| puts m.name }
			ms.each do |m|
				if m.building_id
					if h['id'] == m.building_id
						puts "MATCHED"
						break
					else
						next
					end
				end
				puts h.inspect
				puts m.golf_serialize
				puts h['id']
				if m.longitude && m.latitude && h["latitude"] && h["longitude"]
					close_lat = h["latitude"].to_f - m.latitude
					close_long = h["longitude"].to_f - m.longitude
					if close_lat < 0.005 && close_long < 0.005
						distance = "VERYCLOSE"
						puts distance
						hn = h['name'].gsub('Course', 'Club').gsub('&', 'and')
						mn = m.name.gsub('Course', 'Club').gsub('&', 'and')
						if hn.length > mn.length
							mat = (hn.gsub(mn,'').length + mn.length == hn.length)
						elsif mn.length > hn.length
							mat = (mn.gsub(hn,'').length + hn.length == mn.length)
						end
						if (mat || hn == mn) && ms.length == 1
							puts "--------- ADDING #{m.name} -------------"
							m.update building_id: h['id'].to_i
							@auto_add << { h: h, m: { id: m.id, name: m.name }, d: "VERYCLOSE|#{mat}|#{hn == mn}", ms: ms.length }
							next
						end
					else
						distance = "miles lat  #{close_lat * 69} | miles long #{close_long * 69}"
						puts distance
						if (close_lat * 69) < 3 || (close_long * 69) < 3
							hn = h['name'].gsub('Course', 'Club').gsub('&', 'and')
							mn = m.name.gsub('Course', 'Club').gsub('&', 'and')
							if hn.length > mn.length
								mat = (hn.gsub(mn,'').length + mn.length == hn.length)
							elsif mn.length > hn.length
								mat = (mn.gsub(hn,'').length + hn.length == mn.length)
							end
							if (mat || hn.downcase == mn.downcase) && ms.length == 1
								puts "--------- ADDING #{m.name} -------------"
								m.update building_id: h['id'].to_i
								@auto_add << { h: h, m: { id: m.id, name: m.name }, d: distance, ms: ms.length }
								next
							end
						end
						if (close_lat * 69) > 20 || (close_long * 69) > 20
							puts "--------- AUTO SKIP #{h['name']} #{m.name} -------------"
							@auto_skip << { h: h, m: { id: m.id, name: m.name }, d: distance, ms: ms.length  }
							next
						end
					end
				else
					distance = "NO latitudeor longitude"
					if m.longitude.nil?
						m.longitude = h["longitude"]
					end
					if m.latitude.nil?
						m.latitude = h["latitude"]
					end
					m.save
				end
				puts "Should we add the ID y/n?"
				res = gets
				res.chomp!
				if res == 'y'
					m.update building_id: h['id'].to_i
					@user_add << { h: h, m: { id: m.id, name: m.name }, d: distance, ms: ms.length }
				end
			end
		end
	end

	def chs
		resp = get 'channels'
		if resp[:status] == 1
			raw = resp[:data]["ArrayOfChannel"]["Channel"]
			ary = []

			raw.each do |cc|
				puts cc.inspect
				a = cc["golfFacilities"]["GolfFacility"]
				a = [a] unless a.kind_of?(Array)
				ary.concat a
			end

			ary
		else
			resp[:data]
		end
	end

	def gfs
		resp = get 'golf-facilities'
		if resp[:status] == 1
			@courses = resp[:data]["ArrayOfGolfFacility"]["GolfFacility"]
		else
			resp[:data]
		end
	end

    def get resource
        begin
            res = RestClient.get(
                "#{@api_url}/#{resource}",
                { content_type: 'text/xml', UserName: @username, Password: @password }
            )
            resp = Nokogiri::XML(res.body)
            h = Hash.from_xml(resp.to_s)
            return @response = { status: 1, data: h }
        rescue => e
            puts "\n\OpsGolfnowBds Error code = #{e.inspect}\n\n"
            if e.nil?
                ress = { "response_code" => "ERROR", "response_text" => 'Contact Support', "code" => 400, "data" => [] }
                return @response = { status: 0, data: ress, res: ress }
            else
                return @response = { status: 0, data: e, error: e }
            end
        end
    end


    def mock
		[{"country"=>"US", "currencyCode"=>"USD", "id"=>"1", "latitude"=>"45.483604", "longitude"=>"-122.914352", "name"=>"The Reserve Vineyards and Golf Club - South Course", "stateOrProvince"=>"OR", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"3", "latitude"=>"33.6882", "longitude"=>"-112.3431", "name"=>"Corte Bella Golf Club", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"5", "latitude"=>"36.115309", "longitude"=>"-115.055737", "name"=>"Stallion Mountain Golf Club", "stateOrProvince"=>"NV", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"6", "latitude"=>"33.590745", "longitude"=>"-111.908986", "name"=>"Starfire Golf Club", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"7", "latitude"=>"33.799263", "longitude"=>"-111.928", "name"=>"The Boulders Golf Club", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"8", "latitude"=>"39.769591", "longitude"=>"-120.522509", "name"=>"The Dragon at Nakoma Golf Resort", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"11", "latitude"=>"32.212977", "longitude"=>"-111.043531", "name"=>"Starr Pass Golf Club", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"12", "latitude"=>"33.375756", "longitude"=>"-111.971668", "name"=>"Arizona Grand Golf Course", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"13", "latitude"=>"33.50741", "longitude"=>"-112.031029", "name"=>"Arizona Biltmore Golf Club - Adobe Course", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"14", "latitude"=>"32.221667", "longitude"=>"-110.925833", "name"=>"GolfNow.com/Tucson", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"20", "latitude"=>"33.907679", "longitude"=>"-117.815666", "name"=>"Black Gold Golf Club", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"21", "latitude"=>"33.492403", "longitude"=>"-111.673513", "name"=>"Las Sendas Golf Club", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"25", "latitude"=>"36.632772", "longitude"=>"-121.819251", "name"=>"Bayonet", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"26", "latitude"=>"33.442042", "longitude"=>"-112.320442", "name"=>"Coldwater G.C.", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"27", "latitude"=>"33.473535", "longitude"=>"-117.59691", "name"=>"Talega Golf Club", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"29", "latitude"=>"32.870522", "longitude"=>"-96.465616", "name"=>"Buffalo Creek Golf Club", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"30", "latitude"=>"32.95692", "longitude"=>"-96.947745", "name"=>"Riverchase Golf Club", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"31", "latitude"=>"32.79895", "longitude"=>"-97.058197", "name"=>"Riverside Golf Course - Dallas", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"32", "latitude"=>"32.956149", "longitude"=>"-96.533247", "name"=>"Waterview Golf Club", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"33", "latitude"=>"33.1523", "longitude"=>"-96.8499", "name"=>"The Trails of Frisco", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"35", "latitude"=>"32.696849", "longitude"=>"-97.774291", "name"=>"Canyon West Golf Club", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"38", "latitude"=>"32.998", "longitude"=>"-96.558", "name"=>"Woodbridge Golf Club", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"39", "latitude"=>"33.434665", "longitude"=>"-112.548923", "name"=>"Sundance Golf Club", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"41", "latitude"=>"33.088665", "longitude"=>"-96.9207", "name"=>"Stewart Peninsula Golf Course", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"42", "latitude"=>"33.17928", "longitude"=>"-96.60102", "name"=>"Oak Hollow Golf Course", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"43", "latitude"=>"32.539867", "longitude"=>"-96.659431", "name"=>"Old Brickyard Golf Course", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"44", "latitude"=>"29.643434", "longitude"=>"-98.66306", "name"=>"GolfNow.com/San Antonio", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"45", "latitude"=>"33.845326", "longitude"=>"-117.619628", "name"=>"GolfNow.com/Orange County", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"46", "latitude"=>"33.730817", "longitude"=>"-117.934491", "name"=>"David L. Baker Golf Course", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"47", "latitude"=>"33.451044", "longitude"=>"-112.069304", "name"=>"GolfNow.com/Phoenix", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"48", "latitude"=>"32.766599", "longitude"=>"-97.157636", "name"=>"Waterchase Golf Club", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"50", "latitude"=>"39.199709", "longitude"=>"-120.218355", "name"=>"Links at Squaw Creek", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"51", "latitude"=>"33.33985", "longitude"=>"-112.432108", "name"=>"Golf Club of Estrella", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"53", "latitude"=>"33.676354", "longitude"=>"-111.976347", "name"=>"Wildfire Golf Club - Palmer Course", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"55", "latitude"=>"38.215356", "longitude"=>"-122.237255", "name"=>"Chardonnay Golf Club", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"56", "latitude"=>"33.640289", "longitude"=>"-112.444122", "name"=>"Arizona Traditions Golf Club", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"57", "latitude"=>"33.385106", "longitude"=>"-112.01924", "name"=>"The Legacy Golf Club", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"58", "latitude"=>"33.16177", "longitude"=>"-111.568389", "name"=>"Golf Club at Johnson Ranch", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"59", "latitude"=>"33.538924", "longitude"=>"-111.918034", "name"=>"Silverado Golf Club", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"61", "latitude"=>"33.249009", "longitude"=>"-111.558385", "name"=>"The Links at Queen Creek", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"62", "latitude"=>"33.218369", "longitude"=>"-111.833696", "name"=>"Bear Creek - Bear Championship Course", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"64", "latitude"=>"30.718973", "longitude"=>"-98.252282", "name"=>"Delaware Springs Golf Course", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"66", "latitude"=>"34.165883", "longitude"=>"-118.166425", "name"=>"Brookside Golf Club", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"73", "latitude"=>"38.781914", "longitude"=>"-77.615426", "name"=>"Virginia Oaks Golf Club", "stateOrProvince"=>"VA", "timeZoneOffset"=>"-4"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"74", "latitude"=>"38.947997", "longitude"=>"-77.356062", "name"=>"Reston National Golf Course", "stateOrProvince"=>"VA", "timeZoneOffset"=>"-4"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"75", "latitude"=>"38.707214", "longitude"=>"-77.532749", "name"=>"Bristow Manor Golf Club", "stateOrProvince"=>"VA", "timeZoneOffset"=>"-4"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"76", "latitude"=>"34.162306", "longitude"=>"-118.193173", "name"=>"Scholl Canyon Golf and Tennis Club", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"78", "latitude"=>"33.100745", "longitude"=>"-96.92688", "name"=>"The Tribute Golf Club", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"80", "latitude"=>"33.627651", "longitude"=>"-111.937448", "name"=>"Kierland Golf Club", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"81", "latitude"=>"41.298554", "longitude"=>"-74.18508", "name"=>"The Golf Club at Mansion Ridge", "stateOrProvince"=>"NY", "timeZoneOffset"=>"-4"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"82", "latitude"=>"32.94643", "longitude"=>"-80.138498", "name"=>"Wescott Golf Club", "stateOrProvince"=>"SC", "timeZoneOffset"=>"-4"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"83", "latitude"=>"32.787742", "longitude"=>"-79.899597", "name"=>"Patriots Point Golf Links", "stateOrProvince"=>"SC", "timeZoneOffset"=>"-4"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"90", "latitude"=>"30.234154", "longitude"=>"-81.660003", "name"=>"GolfNow.com/Jacksonville", "stateOrProvince"=>"FL", "timeZoneOffset"=>"-4"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"97", "latitude"=>"37.588118", "longitude"=>"-122.069091", "name"=>"GolfNow.com/San Francisco", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"98", "latitude"=>"36.991749", "longitude"=>"-122.007973", "name"=>"DeLaveaga Golf Course", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"99", "latitude"=>"30.56533", "longitude"=>"-97.666579", "name"=>"Teravista Golf Club", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"100", "latitude"=>"38.244551", "longitude"=>"-122.584639", "name"=>"Adobe Creek Golf Club", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"101", "latitude"=>"37.003992", "longitude"=>"-121.611958", "name"=>"Eagle Ridge Golf Club", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"102", "latitude"=>"37.928467", "longitude"=>"-121.739005", "name"=>"Shadow Lakes Golf Club", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"106", "latitude"=>"37.663678", "longitude"=>"-121.696562", "name"=>"Poppy Ridge Golf Course", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"107", "latitude"=>"36.519323", "longitude"=>"-121.806587", "name"=>"Carmel Valley Ranch **New**", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"110", "latitude"=>"33.270269", "longitude"=>"-111.987419", "name"=>"Whirlwind Golf Club- Devil's Claw", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"111", "latitude"=>"33.800226", "longitude"=>"-111.875603", "name"=>"Legend Trail Golf Club", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"115", "latitude"=>"33.790163", "longitude"=>"-111.991673", "name"=>"Dove Valley Ranch", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"117", "latitude"=>"45.523668", "longitude"=>"-122.674713", "name"=>"GolfNow.com/Oregon", "stateOrProvince"=>"OR", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"120", "latitude"=>"33.379248", "longitude"=>"-111.693664", "name"=>"Superstition Springs Golf Club", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"121", "latitude"=>"33.37066", "longitude"=>"-111.829834", "name"=>"Kokopelli Golf Club", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"122", "latitude"=>"33.596638", "longitude"=>"-111.986572", "name"=>"Stonecreek Golf Club", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"123", "latitude"=>"33.335518", "longitude"=>"-111.763261", "name"=>"Western Skies Golf Club", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"124", "latitude"=>"38.015922", "longitude"=>"-122.674195", "name"=>"San Geronimo Golf Course", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"125", "latitude"=>"33.675996", "longitude"=>"-112.203333", "name"=>"Legend at Arrowhead", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"126", "latitude"=>"36.542671", "longitude"=>"-121.887854", "name"=>"Rancho Canada", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"127", "latitude"=>"36.575074", "longitude"=>"-121.789923", "name"=>"Laguna Seca Golf Ranch", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"128", "latitude"=>"36.161161", "longitude"=>"-115.139465", "name"=>"GolfNow.com/Las Vegas", "stateOrProvince"=>"NV", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"129", "latitude"=>"38.269615", "longitude"=>"-122.278034", "name"=>"Napa Golf Course", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"130", "latitude"=>"37.558552", "longitude"=>"-122.385015", "name"=>"Crystal Springs Golf Course", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"131", "latitude"=>"38.362589", "longitude"=>"-122.707307", "name"=>"Foxtail Golf Club North", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"132", "latitude"=>"36.360826", "longitude"=>"-115.3234", "name"=>"Las Vegas Paiute Golf Resort - Snow Mountain Course", "stateOrProvince"=>"NV", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"133", "latitude"=>"38.553938", "longitude"=>"-121.258625", "name"=>"Mather Golf Course", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"135", "latitude"=>"38.709089", "longitude"=>"-121.486816", "name"=>"GolfNow.com/Sacramento", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"136", "latitude"=>"30.271158", "longitude"=>"-97.741701", "name"=>"GolfNow.com/Austin", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"139", "latitude"=>"30.464834", "longitude"=>"-97.578723", "name"=>"Blackhawk Golf Club", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"140", "latitude"=>"38.828806", "longitude"=>"-121.239444", "name"=>"Whitney Oaks Golf Club", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"141", "latitude"=>"38.949297", "longitude"=>"-121.076868", "name"=>"The Ridge Golf Club", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"142", "latitude"=>"34.135632", "longitude"=>"-117.783288", "name"=>"San Dimas Canyon Golf Club", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"144", "latitude"=>"38.916934", "longitude"=>"-121.290589", "name"=>"Lincoln Hills - Orchard", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"145", "latitude"=>"30.425465", "longitude"=>"-98.000119", "name"=>"Lago Vista Golf Course", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"146", "latitude"=>"30.425465", "longitude"=>"-98.000119", "name"=>"Highland Lakes Golf Course", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"149", "latitude"=>"38.313833", "longitude"=>"-123.027266", "name"=>"The Links at Bodega Harbour", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"151", "latitude"=>"30.55242", "longitude"=>"-97.54936", "name"=>"Star Ranch", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"152", "latitude"=>"35.550245", "longitude"=>"-115.419359", "name"=>"Primm Valley Golf Club - Desert Course", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"154", "latitude"=>"45.610675", "longitude"=>"-123.095541", "name"=>"Quail Valley Golf Course", "stateOrProvince"=>"OR", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"155", "latitude"=>"45.33447", "longitude"=>"-121.95837", "name"=>"The Resort at The Mountain", "stateOrProvince"=>"OR", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"156", "latitude"=>"45.379161", "longitude"=>"-122.575836", "name"=>"Stone Creek Golf Club", "stateOrProvince"=>"OR", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"157", "latitude"=>"35.960535", "longitude"=>"-114.860601", "name"=>"Boulder Creek Golf Club", "stateOrProvince"=>"NV", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"160", "latitude"=>"37.438138", "longitude"=>"-121.872667", "name"=>"Spring Valley Golf Course", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"161", "latitude"=>"37.724829", "longitude"=>"-122.199078", "name"=>"Metropolitan Golf Links", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"162", "latitude"=>"41.272505", "longitude"=>"-96.099445", "name"=>"Miracle Hill Golf and Tennis", "stateOrProvince"=>"NE", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"166", "latitude"=>"30.196365", "longitude"=>"-97.922805", "name"=>"Grey Rock Golf Club", "stateOrProvince"=>"TX", "timeZoneOffset"=>"-5"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"167", "latitude"=>"33.650807", "longitude"=>"-112.402222", "name"=>"Granite Falls Golf Course-North", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"168", "latitude"=>"33.63313", "longitude"=>"-112.288835", "name"=>"Sun City Riverview Golf Course", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"169", "latitude"=>"33.427151", "longitude"=>"-111.649875", "name"=>"Viewpoint Golf Resort", "stateOrProvince"=>"AZ", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"171", "latitude"=>"32.767231", "longitude"=>"-117.171092", "name"=>"Riverwalk Golf Club", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"172", "latitude"=>"38.683559", "longitude"=>"-121.158409", "name"=>"Empire Ranch Golf Club", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"174", "latitude"=>"38.916934", "longitude"=>"-121.290589", "name"=>"Turkey Creek Golf Course", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"175", "latitude"=>"37.463552", "longitude"=>"-122.428586", "name"=>"Half Moon Bay-Old Course", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"176", "latitude"=>"32.743137", "longitude"=>"-116.894333", "name"=>"Steele Canyon Golf Course", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"177", "latitude"=>"38.775798", "longitude"=>"-121.33093", "name"=>"Woodcreek Golf Club", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"178", "latitude"=>"32.66252", "longitude"=>"-117.028451", "name"=>"Chula Vista Golf Course", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"179", "latitude"=>"38.170193", "longitude"=>"-120.831499", "name"=>"La Contenta Golf Club", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}, {"country"=>"US", "currencyCode"=>"USD", "id"=>"180", "latitude"=>"38.611604", "longitude"=>"-121.316061", "name"=>"Ancil Hoffman Golf Course", "stateOrProvince"=>"CA", "timeZoneOffset"=>"-7"}]
    end


end