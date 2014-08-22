class UserSocial < ActiveRecord::Base
    include ModelValidationHelper

    belongs_to :user
    has_many :dittos, as: :notable

    before_validation     :reject_xxx_emails

    before_validation { |social| social.identifier = strip_and_downcase(identifier)   if is_email? }
    before_validation { |social| social.identifier = extract_phone_digits(identifier) if is_phone? }

    validates_presence_of :identifier, :type_of, :user_id

    validates :identifier , format: { with: VALID_PHONE_REGEX }, :if => :is_phone?
    validates :identifier , format: { with: VALID_EMAIL_REGEX }, :if => :is_email?
    validates_with MultiTypeIdentifierUniqueValidator

    after_create  :subscribe_mailchimp
    after_create  :collect_incomplete_gifts
    after_save    :unsubscribe_mailchimp

    default_scope -> { where(active: true) }  # indexed

    def network
        type_of
    end

private


    def collect_incomplete_gifts
        Resque.enqueue(CollectIncompleteGiftsV2Job, self.id)
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

