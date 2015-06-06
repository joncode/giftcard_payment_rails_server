module Utility

    def create_token
        SecureRandom.urlsafe_base64
    end

	alias_method :generate_token, :create_token

    def create_session_token
    	SecureRandom.urlsafe_base64 + SecureRandom.urlsafe_base64
    end

end
