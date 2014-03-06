class SlicktextGateway
    include HttpModel

    attr_reader :limit, :textword
    attr_accessor :status

    def initialize args={}
        @limit    = args[:limit]
        @textword = args[:textword]
        @status   = nil
    end

	def contacts
		route = SLICKTEXT_URL + "/#{self.textword}/contacts?limit=#{self.limit}"
        resp   = get(token: get_token, route: route)  
        data = JSON.parse resp["data"]
        self.status = resp["status"]
        contact_params_array = []
        data["contacts"].each do |contact|
        	contact_params_array << set_sms_params_hash(contact)
        end
        contact_params_array
	end



	private

		def get_token
			SLICKTEXT_API_KEY
		end

		def set_sms_params_hash contact
	        hsh = {}
	        hsh["service_id"]      = nil
	        hsh["service_type"]    = "slicktext"
	        hsh["textword"]        = contact["textword"]
	        hsh["subscribed_date"] = contact["subscribedDate"]
	        hsh["phone"]           = contact["number"]
	        hsh["gift_id"]         = nil
	        hsh			
		end

end