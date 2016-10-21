class PushUserJob
    extend UrbanAirshipWrap

    @queue = :push

    def self.perform user, alert

        puts "SENDING AT PUSH NOTE for USER ID = #{user.id} | #{alert}"
        ditto = send_push(user, alert)
        return ditto

    rescue
    	puts "No data #{data} ERROR"

    end

end
