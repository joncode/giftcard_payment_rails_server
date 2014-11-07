module Utility

    def create_token
        SecureRandom.urlsafe_base64
    end

    def create_session_token
    	SecureRandom.urlsafe_base64 + SecureRandom.urlsafe_base64
    end

end
