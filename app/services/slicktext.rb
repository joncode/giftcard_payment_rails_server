class Slicktext
    include HTTParty
    base_uri 'api.slicktext.com'

    attr_reader   :textword, :word_id, :limit
    attr_accessor :resp

    KEYS = {:username => SLICKTEXT_PUBLIC, :password => SLICKTEXT_PRIVATE}

    def self.textwords
        options = {}
        options.merge!({:basic_auth => KEYS})
        resp = self.get("/v1/textwords?limit=#{1000}", options)
        if resp.nil? || resp['textwords'].nil?
            puts "... gotten slicktext textwords - no textwords"
        else
            puts "... gotten slicktext textwords - #{resp["textwords"][0]} ..."
        end
        resp["textwords"]
    end

    def initialize word_hsh={}, limit=1000
        @textword = word_hsh["word"]
        @word_id  = word_hsh["id"]
        @limit    = limit
    end

    def sms  options={}
        options.merge!({:basic_auth => KEYS})
        self.resp = self.class.get("/v1/contacts?limit=#{self.limit}&textword=#{self.word_id}", options)
    end

    def get_all options={}
        options.merge!({:basic_auth => KEYS})
        self.resp = self.class.get("/v1/contacts?limit=#{self.limit}", options)
    end

    def textwords options={}
        options.merge!({:basic_auth => KEYS})
        self.resp = self.class.get("/v1/textwords?limit=#{self.limit}", options)
        self.resp["textwords"]

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
            []
        end
    end

    def count
        if self.resp.present? && self.resp["contacts"].present?
            self.resp["contacts"].count
        else
            0
        end
    end

private

    def convert_data contact
        hsh = {}
        hsh["service_id"]      = contact["id"]
        hsh["service"]         = "slicktext"
        hsh["textword"]        = self.textword
        hsh["subscribed_date"] = contact["subscribedDate"].to_datetime
        hsh["phone"]           = convert_phone_number(contact["number"])
        hsh
    end

    def convert_phone_number contact_number
        if contact_number.present?
            converted_number = contact_number.gsub(/[^0-9]/i, '')
            if converted_number[0] == "1"
                converted_number[1..converted_number.length]
            else
                converted_number
            end
        else
            puts " ---------- SLICKTEXT ERROR NO PHONE NUMBER"
        end
    end
end