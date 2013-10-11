class SubscriptionJob

    @queue = :subscription

    def self.perform(user_social_id)
        user_social    = UserSocial.find user_social_id
        if user_social.active
            add_to_mailchimp user_social
        else
            remove_from_mailchimp user_social
        end
    end

private

    def add_to_mailchimp user_social
        user = user_social.user
        mcl = MailchimpList.new(user_social.identifier, user.first_name, user.last_name)
        mcl.subscribe
    end

    def remove_from_mailchimp user_social
        mcl = MailchimpList.new(user_social.identifier)
        mcl.unsubscribe
    end

end

