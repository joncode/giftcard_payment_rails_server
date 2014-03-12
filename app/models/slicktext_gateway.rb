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
            data  = resp["data"]
            self.status   = resp["status"]
            puts "#{resp}"
            failsafe -= 1
            if data["contacts"].kind_of?(Array)
                @rec_contacts << data["contacts"]
                total_count = data["contacts"].count
            else
                total_count = 0
            end
        end until (total_count != self.limit) || (failsafe == 0)

        puts "^^^^^^^^^^^^^^^^^^^^^^^^^^  SLICKTEXT FAILSAFE HIT   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^" if failsafe == 0

        if self.status.to_i == 200
            @rec_contacts.flatten.map do |contact|
                convert_data(contact)
            end
        end
	end

private

	def get_token
		# SLICKTEXT_API_KEY
        # SLICKTEXT_PUBLIC
        "Basic #{SLICKTEXT_PRIVATE}"
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