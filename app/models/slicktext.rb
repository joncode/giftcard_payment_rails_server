class Slicktext
    include HTTParty
    base_uri 'api.slicktext.com'

    attr_reader   :textword, :limit
    attr_accessor :resp

    def initialize textword="itsonme", limit=1000
        @auth = {:username => SLICKTEXT_PUBLIC, :password => SLICKTEXT_PRIVATE}
        @textword = textword
        @limit = 1000
    end

    def sms  options={}
        options.merge!({:basic_auth => @auth})
        self.resp = self.class.get("/v1/contacts?limit=#{self.limit}&textword=#{self.textword}", options)
    end

    def raw_contacts
        self.resp["contacts"]
    end

    def contacts
        if self.resp.present? && self.resp["contacts"].present?
            self.resp["contacts"].map do |c|
                convert_data c
            end
        else
            nil
        end
    end

    def count
        if self.resp.present? && self.resp["contacts"].present?
            self.resp["contacts"].count
        else
            nil
        end
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

