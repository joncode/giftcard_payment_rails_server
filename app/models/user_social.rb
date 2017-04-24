class UserSocial < ActiveRecord::Base
    include ActionView::Helpers::NumberHelper
    include ModelValidationHelper

    default_scope -> { where(active: true) }  # indexed

#   -------------

    before_validation :reject_xxx_emails
    before_validation { |social| social.identifier = strip_and_downcase(identifier)   if is_email? }
    before_validation { |social| social.identifier = extract_phone_digits(identifier) if is_phone? }

#   -------------

    validates_presence_of :identifier, :type_of, :user_id
    validates :identifier , format: { with: VALID_PHONE_REGEX, message: "phone number is invalid" }, if: :is_phone?
    validates :identifier , format: { with: VALID_EMAIL_REGEX, message: "email is invalid" }, if: :is_email?
    validates_with MultiTypeIdentifierUniqueValidator

#   -------------

    before_create :set_user_auth_required

#   -------------

    after_commit :collect_incomplete_gifts
    after_commit :subscribe_mailchimp, on: :create
    after_commit :fire_after_save_queue, on: [:create, :update, :destroy]
    after_commit :unsubscribe_mailchimp, on: [:create, :update, :destroy]

#   -------------

    has_many :dittos, as: :notable
    belongs_to :user

#   -------------

    def phone?
        self.type_of == 'phone'
    end

    def display_net_id
        if phone?
            number_to_phone(self.identifier, area_code: true)
        else
            self.identifier
        end
    end

    def network_id
        identifier
    end

    def network
        type_of
    end

#   -------------

    def authorize
        self.status = 'live'
        self.msg = "Authorized #{DateTime.now.utc} #{self.code}"
        self.code = nil
        save
    end

    def set_reauth(msg: "Please Reauthorize your Facebook account")
        puts "Reauth #{self.id} " + msg.inspect
        update(status: 'reauth', msg: msg)
    end

    def set_user_auth_required
        if self.type_of == 'phone'
            self.status = 'user_auth_required'
            self.msg = 'Please sms authorize phone'
        elsif self.type_of == 'email'
            self.status = 'user_auth_required'
            self.msg = 'Please confirm email'
        end
    end

    def get_auth_code
        if !self.active
            return { success: false,
                error: "#{display_net_id} is deactivated. Cannot Activate" }
        end

        if self.status == 'live'
            return { success: true,
                error: "#{display_net_id} is alreaday activated." }
        end

        int_code = make_integer_code
        if self.update(code: int_code.to_s,
                status: 'activate',
                msg: "Waiting for user authorization")

            if phone?
                OpsTwilio.text(self.identifier, "Your ItsOnMe code is #{hyphen_code(int_code)}")
            end

            return { success: true,
                error: "#{display_net_id} is activated." }
        else
            return { success: false,
                error: "#{display_net_id} #{self.errors.full_messages}. Cannot Activate" }
        end
    end

    def hyphen_code int_code
        c = int_code.to_s
        x = c[0..2]
        y = c[3..5]
        x + '-' + y
    end

    def make_integer_code
        int_code = rand(900000) + 100000
        us = UserSocial.where(code: int_code).first
        if us.length == 0
            return int_code
        else
            return make_integer_code
        end
    end

    def self.double_check_incomplete_gifts
        UserSocial.where("updated_at > ?", 31.minutes.ago).find_each do |us|
            CollectIncompleteGiftsV2Job.perform(us.id)
        end
    end

private


    def fire_after_save_queue
        if thread_on?
            Resque.enqueue(UserAfterSaveJob, self.user_id)
        else
            UserAfterSaveJob.perform(self.user_id)
        end
    end

    def collect_incomplete_gifts
        if self.identifier_changed? && self.active
            puts "Identifier changed, re-running CollectIncompleteGiftsV2Job (140)"
            if thread_on?
                Resque.enqueue(CollectIncompleteGiftsV2Job, self.id)
            else
                CollectIncompleteGiftsV2Job.perform(self.id)
            end
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

