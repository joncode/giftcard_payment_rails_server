class SubscriptionJob

    @queue = :subscription

    def self.perform(user_social_id)
        user_email    = UserSocial.find user_social_id
        user          = user_email.user
        mcl           = MailchimpList.new(user_email.identifier, user.first_name, user.last_name)
        #puts "here is the MCL = #{mcl.inspect}"
        mcl.subscribe
    end

end