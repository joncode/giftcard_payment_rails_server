class UserSocial < ActiveRecord::Base
    attr_accessible :identifier, :type_of, :user_id

    belongs_to :user

    before_validation :reject_xxx_emails
    validates_presence_of :identifier, :type_of, :user_id
    after_save :update_mailchimp

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

    def update_mailchimp
        if Rails.env.production? || Rails.env.staging?
        	if self.type_of  == "email"
                Resque.enqueue(SubscriptionJob, self.id)
        	end
        end
    end

    def reject_xxx_emails
        if self.type_of  == "email"
            if self.identifier && self.identifier[-3..-1] == "xxx"
                self.identifier = nil
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
#

