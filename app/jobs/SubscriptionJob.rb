class SubscriptionJob

    @queue = :subscription

    def self.perform(user_social_id)
        user_social    = UserSocial.find user_social_id
        if user_social.active
            self.add_to_mailchimp user_social
        else
            self.remove_from_mailchimp user_social
        end
    end

private

    def self.add_to_mailchimp user_social
        user = user_social.user
        mcl = MailchimpList.new(user_social.identifier, user.first_name, user.last_name)
        response = mcl.subscribe
        if response["email"].present?
            UserSocial.find(user_social.id).update_attributes(subscribed_bool: true, subscribed_resp: response)
        end
    end

    def self.remove_from_mailchimp user_social
        mcl = MailchimpList.new(user_social.identifier)
        response = mcl.unsubscribe
        if response["complete"].present? && response["complete"] == true
            UserSocial.find(user_social.id).update_attribute(:subscribed, false)
        end
    end

end

