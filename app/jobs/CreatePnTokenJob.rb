class CreatePnTokenJob

    @queue = :after_save

    def self.perform user_id, pn_token, platform
    	user = User.find user_id
    	user.pn_token = [pn_token, platform]
    end

end