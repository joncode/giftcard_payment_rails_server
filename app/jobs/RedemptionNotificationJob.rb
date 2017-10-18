class RedemptionNotificationJob
    @queue = :subscription

    def self.perform redemption_id, status

		r = Redemption.find(redemption_id)

    	if status == 'failed'
    		Alert.perform("REDEMPTION_SYS", r)
    		Alert.perform("REDEMPTION_MT", r)
    	elsif status == 'done'
    		Alert.perform("REDEMPTION_MT", r)
    	end

    end

end