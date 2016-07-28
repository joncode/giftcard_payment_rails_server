class GeoData

	CONTINENTS = {  "Europe" => "EU",  "Asia" => "AS",  "North America" =>  "NA", "Africa" => "AF", "Antarctica" => "AN", "South America" => "SA" , "Australia" =>"AU" }

	def self.add_geos place, country
		recalc_la = true
		recalc_lo = true
		place.min_latitude = country.min_latitude if (place.min_latitude.nil? || (country.min_latitude.to_f < place.min_latitude))
		place.min_longitude = country.min_longitude if (place.min_longitude.nil? || (country.min_longitude.to_f < place.min_longitude))
		place.max_latitude = country.max_latitude if (place.max_latitude.nil? || (country.max_latitude.to_f > place.max_latitude))
		place.max_longitude = country.max_longitude if (place.max_longitude.nil? || (country.max_longitude.to_f > place.max_longitude))
		if place.latitude.nil?
			place.latitude = country.latitude_dec.to_f
			recalc_la = false unless country.latitude_dec.nil?
		end
		if place.longitude.nil?
			place.longitude = country.longitude_dec.to_f
			recalc_lo = false unless country.longitude_dec.nil?
		end
			# average the lat and long based on new dimensions
		if recalc_la
			latis = (place.max_latitude + place.min_latitude) / 2.0
			lat_diff = (place.latitude - latis)
			if ( lat_diff < -1  ) || ( 1 < lat_diff )
				place.latitude = latis
			end
		end
		if recalc_lo
			longis = (place.max_longitude + place.min_longitude) / 2.0
			long_diff = (place.longitude - longis)
			if ( long_diff < -1 ) || ( 1 < long_diff )
				place.longitude = longis
			end
		end
	end

	def self.perform
		continents
		states
		zips
	end

	def self.continents
		# continents
		cs = ISO3166::Country.countries
		continents = {}
		cs.each do |country|
			if continents[country.continent]
				place = continents[country.continent].reload
			else
				place = Place.new(type_of: 'continent', name: country.continent,
					abbr: CONTINENTS[country.continent], active: true)
			end
			add_geos place, country
			place.save
			continents[country.continent] = place
			nil
		end

		# countries
		cs.each do |country|
			place = Place.find_or_initialize_by(type_of: 'country', name: country.name, abbr: country.alpha2,
					active: true, ccy: country.currency_code, detail: "#{country.subregion} -  #{country.nationality}",)

			add_geos place, country
			place.save
			continent = Place.find_by(name: country.continent, type_of: 'continent')
			PlaceGraph.add_node ch: place, pa: continent
		end
	end

	def self.states
		# states
		cs = ISO3166::Country.countries
		cs.each do |country|
			states = country.subdivisions
			ccy = country.currency_code
			country_abbr = country.alpha2
			states.each do |state_ary|
				abbr = state_ary[0]
				hsh = state_ary[1]

				place = Place.new(type_of: 'state', name: hsh['name'], abbr: abbr, active: true)

				if place.id.nil?
					detail = hsh['names'].kind_of?(Array) ? hsh['names'].join(', ') : hsh['names']
					place.detail = detail
					place.ccy = ccy
					place.longitude = hsh['longitude'].to_f
					place.latitude = hsh['latitude'].to_f
					place.min_latitude = hsh['min_latitude'].to_f
					place.max_latitude = hsh['max_latitude'].to_f
					place.min_longitude = hsh['min_longitude'].to_f
					place.max_longitude = hsh['max_longitude'].to_f
				end

				# puts place.inspect
				place.save
				country_place = Place.find_by(abbr: country_abbr, type_of: 'country')
				PlaceGraph.add_node ch: place, pa: country_place
			end
		end
	end

	def self.zips

		# zipcodes and cities
		usa = P.usa
		continent = usa.get(pa: 'continent').first
		buffer = '00000'
		num = 96913
		last_state = Place.new(abbr: "JKSHDFSYFUSGDF")
		last_tz = Place.new(abbr: "JKSHDFSYFUSGDF")
		last_city = Place.new(abbr: "JKSHDFSYFUSGDF")
		while num < 100000
			str = num.to_s
			len = str.length
			tots = buffer + str
			index = 5 - (5 - len)
			new_str = tots[index .. -1]
			zipobj = ZipCodes.identify(new_str)
			if zipobj
				# {:state_code=>"NY", :state_name=>"New York", :city=>"New York City", :time_zone=>"America/New_York"}
				if last_state.abbr == zipobj[:state_code] || last_state.name == zipobj[:state_name]
					state = last_state
				else
					state = usa.get(ch: 'state', abbr: zipobj[:state_code]).first
					if state.nil?
						state = usa.get(ch: 'state', abbr: zipobj[:state_name]).first
					end
					last_state = state unless state.nil?
				end

				if last_tz.abbr == zipobj[:time_zone]
					timezone = last_tz
				else
					if zipobj[:time_zone]
						begin
							tz_abbr = Time.now.in_time_zone(zipobj[:time_zone]).strftime('%Z')
						rescue
							tz_abbr = zipobj[:time_zone]
						end
						timezone = Place.find_or_create_by(abbr: tz_abbr, name: zipobj[:time_zone], type_of: 'timezone')

						if timezone.persisted?
							PlaceGraph.add_node ch: timezone, pa: continent
							PlaceGraph.add_node ch: timezone, pa: usa
						end

						if (timezone.persisted? && state.persisted?)
							PlaceGraph.add_node ch: state, pa: timezone
						end

						last_tz = timezone if timezone.persisted?
					end
				end
				if last_city.abbr == zipobj[:city]
					city = last_city
				else
					city = Place.find_or_create_by(abbr: zipobj[:city], name: zipobj[:city], detail: zipobj[:state_name], tz: zipobj[:time_zone], type_of: 'city', ccy: usa.ccy)
					PlaceGraph.add_node ch: city, pa: state if !state.nil? && state.persisted?
					last_city = city
				end

				zip = Place.create(abbr: new_str, name: new_str, detail: 'USA zipcode', tz: zipobj[:time_zone], type_of: 'zip', ccy: usa.ccy)
				PlaceGraph.add_node ch: zip, pa: city
			end
			num += 1
		end
	end


end