module MerchantSerializers

	def serialize
		prov_hash  = self.serializable_hash only: [ :ccy, :r_sys, :name, :phone, :latitude, :longitude, :zinger, :region_id, :region_name,  :city_id]
		prov_hash["provider_id"]  = self.id
		prov_hash["merchant_id"]  = self.id
		prov_hash["photo"]        = self.get_photo
		prov_hash['city']		  = self.city_name
		prov_hash["full_address"] = self.full_address
		prov_hash["live"]         = self.live_int
		prov_hash["desc"]		  = self.description
		return prov_hash
	end

	def client_serialize
		prov_hash  = self.serializable_hash only: [ :ccy, :r_sys, :name, :phone, :latitude, :longitude, :region_id, :region_name,  :city_id]
		prov_hash["provider_id"]  = self.id
		prov_hash["merchant_id"]  = self.id
		prov_hash["photo"]        = self.get_photo(default: false)
		prov_hash['city']		  = self.city_name
		prov_hash["address"]      = self.complete_address
		prov_hash["live"]         = self.live_int.to_i
		return remove_nils(prov_hash)
	end

	alias :to_hash :serialize

	def admt_serialize
		prov_hash  = self.serializable_hash only: [ :ccy, :r_sys, :name, :address, :state, :brand_id, :building_id ]
		prov_hash["provider_id"]  = self.id
		prov_hash["merchant_id"]  = self.id
		prov_hash['city']		  = self.city_name
		prov_hash["mode"]         = self.mode
		return prov_hash
	end

	def merchantize
		prov_hash  = self.serializable_hash only: [ :ccy, :r_sys, :name, :phone, :sales_tax, :token, :address, :city_name, :state, :zip, :zinger, :description]
		prov_hash["photo"] = self.get_photo
		return prov_hash
	end

	def web_serialize
		prov_hash  = self.serializable_hash only: [ :zinger, :ccy, :r_sys, :name, :phone, :latitude, :longitude, :region_id, :region_name,  :city_id]
		prov_hash["loc_id"]     = self.id
		prov_hash["photo"]      = self.get_photo(default: false)
		prov_hash["logo"]       = self.get_logo_web
		prov_hash["loc_street"] = self.address
		prov_hash["loc_city"]   = self.city_name
		prov_hash["loc_state"]  = self.state
		prov_hash["loc_zip"]    = self.zip
		prov_hash["live"]       = self.live
		prov_hash["detail"]		= self.description
		# multi_redemption_web_keys prov_hash
		prov_hash
	end

	def redemption_serialize
		prov_hash  = self.serializable_hash only: [ :ccy, :r_sys, :name, :phone, :latitude, :longitude, :region_id, :region_name,  :city_id]
		prov_hash["loc_id"]     = self.id
		prov_hash["photo"]      = self.get_photo(default: false)
		prov_hash["logo"]       = self.get_logo_web
		prov_hash["loc_street"] = self.address
		prov_hash
	end

private

	def multi_redemption_web_keys prov_hash
        if self.client.present?
            arg_scope = proc { ["All"] }
            redemption_merchants = self.client.contents(:merchants, &arg_scope)
            if redemption_merchants != ["All"]
                redemption_merchants = redemption_merchants.serialize_objs(:redemption)
            end
            prov_hash['redeem_locs'] = redemption_merchants
        end
    end

end