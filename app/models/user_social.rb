class UserSocial < ActiveRecord::Base
    include ActionView::Helpers::NumberHelper
    include ModelValidationHelper

    default_scope -> { where(active: true) }  # indexed
    scope :primary, -> { where(primary: true) }

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

    def primary?   ; primary    ; end
    def network_id ; identifier ; end
    def network    ; type_of    ; end

    def phone?    ; (type_of.to_s == 'phone')    ; end
    def email?    ; (type_of.to_s == 'email')    ; end
    def facebook? ; (type_of.to_s == 'facebook') ; end
    def twitter?  ; (type_of.to_s == 'twitter')  ; end

    def display_net_id
        if phone?
            number_to_phone(self.identifier, area_code: true)
        else
            self.identifier
        end
    end

#   -------------

    def self.ensure_primaries(user_id)
        # Set default primaries if either network has zero or >1 primaries
        # returns status array:  nil for unchanged, true for success, false for error
        %w[email phone].map do |network|
            next if self.unscoped.primary.where(user_id: user_id, type_of: network).count == 1
            self.set_default_primary!(user_id, network)
        end
    end

    def self.set_default_primary!(user_id, network)
        self.set_default_primary(user_id, network, bypass_hooks: true)
    end

    def self.set_default_primary(user_id, network, bypass_hooks: false)
        puts "[model UserSocial :: set_default_primary#{bypass_hooks ? '!' : ''}(user_id:#{user_id}, network:#{network})]"

        # Clear all primaries for this user and network type, including inactives
        self.unscoped.where(user_id: user_id, type_of: network).update_all(primary: false)

        # Find the best UserSocial and set it as primary (if it exists)
        social = self.best(user_id, network)
        return unless social.present?

        # Use #update_column to bypass the expensive `after_commit` hooks, if requested
        social.update_column(:primary, true)  if     bypass_hooks
        social.update(primary: true)          unless bypass_hooks
        social.reload
    end

    def set_primary
        _signature = "[model UserSocial(#{self.id}) :: set_primary]"
        puts _signature
        puts " | User ID:    #{self.user_id}"
        puts " | Network:    #{self.type_of}"
        puts " | Identifier: #{self.identifier}"

        # Clear all primaries for this user and network type, including inactives
        UserSocial.unscoped.primary.where(user: self.user, type_of: self.type_of).update_all(primary: false)

        # Set this record as primary
        self.update(primary: true)

        # Promote to user#email, user#phone, etc. (if applicable)
        self.user.update(self.type_of => self.identifier)  if [:email, :phone, :twitter, :facebook].include?(self.type_of.to_sym)

        # Catch and log failures to ensure we can recover the data.
        unless self.reload.primary?
            ids  = UserSocial.unscoped.primary.where(user: self.user, type_of: self.type_of).pluck(:id) - [self.id]
            msg  = "#{_signature}  Error: Could not promote #{self.id} to primary."
            msg += "  These should be non-primary: #{ids.inspect}"  unless ids.empty?
            puts msg
            return false  # Signal an error
        end

        # return self for chaining
        self.reload
    end


    def deactivate(force: false)
        _signature = "[model UserSocial(#{self.id}) :: deactivate#{force ? '(force)' : ''}]"

        # Deactivating non-primary contacts is nice and straightforward
        unless self.primary?
            puts "#{_signature}  Deactivating #{self.type_of}"
            self.update(active: false)
            return self.reload
        end

        # Don't allow deactivating a user's sole primary email (unless forced or the user is deactivated)
        if self.email? && UserSocial.where(user: self.user, type_of: self.type_of).where.not(identifier: self.identifier).empty?
            # Allow force-deactivating, and deactivating sole primary emails of deactivated users
            if force || !self.user.active
                puts "#{_signature}  #{force ? 'Force-d' : 'D'}eactivating primary #{self.type_of}"
                self.update(primary: false, active: false)
                self.user.update(self.type_of => nil)   # Update the corresponding column on the user
                return self.reload
            end
            puts "#{_signature}  Refusing to deactivate User##{self.user_id}'s only #{self.type_of} contact."
            return false  # Silent failures are terrible.  Return false instead of `self` to indicate failure (and discourage unsafe chaining)
        end

        puts "#{_signature}  Deactivating primary #{self.type_of} and attempting to promote new UserSocial"
        self.update(primary: false, active: false)                  # Deactivate and demote the primary contact
        self.user.update(self.type_of => nil)                       # Update the corresponding column on the user  ##! Will break if type_of is not within [phone, email, twitter, facebook]
        UserSocial.set_default_primary(self.user_id, self.type_of)  # Pick a new primary contact
        return self.reload
    end

#   -------------

    def self.best(user_id, network)
        # Pick out the best available UserSocial
        socials = UserSocial.where(user_id: user_id, type_of: network).order(created_at: :desc)
        social  = nil
        social ||= socials.where(primary: true).first
        social ||= socials.where(status: :live).first
        social ||= socials.first
        social
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
        update_column(:status, 'reauth')
        update_column(:msg, msg)
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

