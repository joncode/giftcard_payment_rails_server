class SubscriptionJob

    @queue = :subscription

    def self.perform(user_social_id)
        user_social = UserSocial.where(id: user_social_id).first
        if  user_social
            if user_social.active
                self.add_to_mailchimp user_social
            else
                self.remove_from_mailchimp user_social
            end
        else
            puts "Unable to find user social in subscription job via ID = #{user_social_id}"
        end
    end

private

    def self.add_to_mailchimp user_social
        user = user_social.user
        mcl = MailchimpList.new(user_social.identifier, user.first_name, user.last_name)
        mcl.subscribe
    end

    def self.remove_from_mailchimp user_social
        mcl = MailchimpList.new(user_social.identifier)
        mcl.unsubscribe
    end

end

