class Slicktext
    include HTTParty
    base_uri 'api.slicktext.com'

    attr_reader   :textword, :limit, :textwords_list
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

    def get_all options={}
        options.merge!({:basic_auth => @auth})
        self.resp = self.class.get("/v1/contacts?limit=#{self.limit}", options)
    end

    def textwords options={}
        options.merge!({:basic_auth => @auth})
        self.resp = self.class.get("/v1/textwords?limit=#{self.limit}", options)
        @textwords_list = self.resp["textwords"]
    end

    def word_id textword
        if self.textwords_list.nil?
            textwords
        end
        if self.textwords_list.present?
            t_word = self.textwords_list.select {|t| t["word"] == textword }
            t_word[0]["id"]
        end
    end

    def textword_for word_id
        if self.textwords_list.nil?
            textwords
        end
        if self.textwords_list.present?
            t_word = self.textwords_list.select {|t| t["id"] == word_id }
            t_word[0]["word"]
        end
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

