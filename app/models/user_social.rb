class UserSocial < ActiveRecord::Base
    attr_accessible :identifier, :type_of, :user_id, :subscribed

    belongs_to :user

    before_validation     :reject_xxx_emails

    validates_presence_of :identifier, :type_of, :user_id

    after_create          :subscribe_mailchimp
    after_save            :unsubscribe_mailchimp

    default_scope where(active: true)

    def self.deactivate_all user
        socials = user.user_socials
        socials.each do |social|
            social.deactivate
        end
    end

    def deactivate
        self.update_attribute(:active, false)
    end

private

    def subscribe_mailchimp
    	if self.type_of  == "email"
            unless Rails.env.development?
                Resque.enqueue(SubscriptionJob, self.id)
        	end
        end
    end

    def unsubscribe_mailchimp
        unless Rails.env.development?
            if self.type_of  == "email" && !self.active
                Resque.enqueue(SubscriptionJob, self.id)
            end
        end
    end

    def reject_xxx_emails
        if self.type_of  == "email"
            if self.identifier && self.identifier[-3..-1] == "xxx"
                self.identifier = nil
                self.user_id    = nil
            end
        end
    end

end

# == Schema Information
#
# Table name: user_socials
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  type_of    :string(255)
#  identifier :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  active     :boolean         default(TRUE)
#  subscribed :boolean default false

