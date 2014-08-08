require 'resque/plugins/resque_heroku_autoscaler'

class SubscriptionJob
    #extend Resque::Plugins::HerokuAutoscaler

    @queue = :subscription

    def self.perform(user_social_id)
        if user_social = UserSocial.unscoped.where(id: user_social_id).first
            if user_social.active
                self.add_to_mailchimp user_social
                puts "add to mailchimp"
            else
                self.remove_from_mailchimp user_social
                puts "remove from mailchimp"
            end
        else
            puts "Unable to find user social in subscription job via ID = #{user_social_id}"
        end
    end

private

    def self.add_to_mailchimp user_social
        user = user_social.user
        mcl = MailchimpList.new(user_social.identifier, user.first_name, user.last_name)
        response = mcl.subscribe
        Ditto.subscription_email_create(response, user_social.id)
        puts "add_to_mailchimp Response -> \n #{response.inspect} \n"
        if response["email"].present?
            user_social.update_attribute(:subscribed, true)
        end
    end

    def self.remove_from_mailchimp user_social
        mcl = MailchimpList.new(user_social.identifier)
        response = mcl.unsubscribe
        Ditto.subscription_email_create(response, user_social.id)
        puts "remove_from_mailchimp Response -> \n #{response.inspect} \n"
        if response["complete"].present? && response["complete"] == true
            user_social.update_attribute(:subscribed, false)
        end
    end

end

