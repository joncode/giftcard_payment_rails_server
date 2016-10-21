class PushUserJob
    extend UrbanAirshipWrap

    @queue = :push

    def self.perform user_or_id, alert

    	if user_or_id.kind_of?(User)
    		user = user_or_id
    	else
    		user = User.find user_or_id
    	end

        puts "SENDING AT PUSH NOTE for USER ID = #{user.id} | #{alert}"
        ditto = send_push(user, alert)
        return ditto

    rescue
    	puts "No data #{data} ERROR"

    end

end
