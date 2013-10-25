class AuthTransaction

    attr_reader :fields

    def initialize req_json=nil
        req_json = fake_req_json if req_json.nil?
        @fields = JSON.parse req_json
        @fields["card_num"] = "8574986798459834"
        @fields.symbolize_keys!
    end

    def fake_req_json
        "{\"first_name\":\"David\",\"last_name\":\"Leibner\",\"method\":\"CC\",\"card_num\":\"XXXX4628\",\"exp_date\":\"0617\",\"amount\":\"16.8\"}"
    end

end