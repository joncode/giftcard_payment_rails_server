module Utility

    def create_token
        SecureRandom.urlsafe_base64
    end

end
