class UserSocial < ActiveRecord::Base

    belongs_to :user

    before_validation     :reject_xxx_emails

    validates_presence_of :identifier, :type_of, :user_id

    validates_with MultiTypeIdentifierUniqueValidator
    validates :identifier , format: { with: VALID_PHONE_REGEX }, :if => :is_phone?
    validates :identifier , format: { with: VALID_EMAIL_REGEX }, :if => :is_email?

    before_save           :extract_phone_digits
    after_create          :subscribe_mailchimp
    after_save            :unsubscribe_mailchimp

    default_scope -> { where(active: true) }  # indexed

private

    def extract_phone_digits
        if self.type_of == 'phone'
            phone_match = self.identifier.to_s.match(VALID_PHONE_REGEX)
            self.identifier  = phone_match[1] + phone_match[2] + phone_match[3]
        end
    end

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

    def is_email?
        self.type_of == "email"
    end

    def is_phone?
        self.type_of == "phone"
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
#  subscribed :boolean         default(FALSE)
#  name       :string(255)
#  birthday   :date
#  handle     :string(255)
#

