class AuthResponse

    attr_reader :fields

    def initialize resp_json=nil
        resp_json = fake_resp_json if resp_json.nil?
        @fields = JSON.parse resp_json
    end

    def transaction_id
        @fields["transaction_id"]
    end
    
    def response_code
        @fields["response_code"]
    end

    def response_reason_text
        @fields["response_reason_text"]
    end

    def response_reason_code
        @fields["response_reason_code"]
    end

    def fake_resp_json
        "{\"response_code\":\"1\",\"response_subcode\":\"1\",\"response_reason_code\":\"1\",\"response_reason_text\":\"This transaction has been approved.\",\"authorization_code\":\"181515\",\"avs_response\":\"P\",\"transaction_id\":\"5573834199\",\"invoice_number\":\"\",\"description\":\"\",\"amount\":\"16.8\",\"method\":\"CC\",\"transaction_type\":\"auth_capture\",\"customer_id\":\"\",\"first_name\":\"David\",\"last_name\":\"Leibner\",\"company\":\"\",\"address\":\"\",\"city\":\"\",\"state\":\"\",\"zip_code\":\"\",\"country\":\"\",\"phone\":\"\",\"fax\":\"\",\"email_address\":\"\",\"ship_to_first_name\":\"\",\"ship_to_last_name\":\"\",\"ship_to_company\":\"\",\"ship_to_address\":\"\",\"ship_to_city\":\"\",\"ship_to_state\":\"\",\"ship_to_zip_code\":\"\",\"ship_to_country\":\"\",\"tax\":\"0.0\",\"duty\":\"0.0\",\"freight\":\"0.0\",\"tax_exempt\":\"\",\"purchase_order_number\":\"\",\"md5_hash\":\"1E902F33186C2766D04D491478CBD1F5\",\"card_code_response\":\"\",\"cardholder_authentication_verification_response\":\"\",\"account_number\":\"XXXX4628\",\"card_type\":\"Visa\"}"
    end

end