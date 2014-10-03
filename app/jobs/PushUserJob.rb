class PushUserJob
    extend UrbanAirshipWrap

    @queue = :push

    def self.perform data
    	begin
    		user_id = data["user_id"]
    		alert   = data["alert"]
	        user = User.find user_id
	        return nil unless user.respond_to?(:ua_alias)
	        payload = self.format_payload(alert, user, 3)
	        puts "SENDING AT PUSH NOTE for USER ID = #{user.id} | #{payload}"
	        self.ua_push(payload, user_id, "User")
	    rescue
	    	puts "No data #{data} ERROR"
	    end
    end

end
