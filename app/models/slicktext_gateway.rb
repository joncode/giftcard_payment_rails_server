class SlicktextGateway
    include HttpModel

    attr_reader :limit, :textword
    attr_accessor :status, :rec_contacts

    def initialize args={}
        @limit    = args[:limit]
        @textword = args[:textword]
        @status   = nil
        @rec_contacts = []
    end

	def contacts
		route = SLICKTEXT_URL + "/#{self.textword}/contacts?limit=#{self.limit}"
        failsafe = 10
        begin
            resp  = get(token: get_token, route: route)
            data  = JSON.parse resp["data"]
            self.status   = resp["status"]
            @rec_contacts << data["contacts"]
            failsafe -= 1
        end until (data["contacts"].count != self.limit) || (failsafe == 0)

        puts "^^^^^^^^^^^^^^^^^^^^^^^^^^  SLICKTEXT FAILSAFE HIT   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^" if failsafe == 0

        @rec_contacts.flatten.map do |contact|
            convert_data(contact)
        end
	end

private

	def get_token
		SLICKTEXT_API_KEY
	end

	def convert_data contact
        hsh = {}
        hsh["service_id"]      = contact["id"]
        hsh["service"]         = "slicktext"
        hsh["textword"]        = contact["textword"]
        hsh["subscribed_date"] = contact["subscribedDate"].to_datetime
        hsh["phone"]           = convert_phone_number(contact["number"])
        hsh
	end

    def convert_phone_number contact_number
        contact_number.gsub(/[^0-9]/i, '')
    end

end