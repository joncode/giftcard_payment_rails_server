class UserSocial < ActiveRecord::Base
    
    belongs_to :user

    before_validation     :reject_xxx_emails

    validates_presence_of :identifier, :type_of, :user_id

    validates_with TypeIdValidator
    validates :identifier , format: { with: VALID_PHONE_REGEX }, if: :is_phone
    validates :identifier , format: { with: VALID_EMAIL_REGEX }, if: :is_email

    after_create          :subscribe_mailchimp
    after_save            :unsubscribe_mailchimp

    default_scope -> { where(active: true) }  # indexed

    def is_email
        self.type_of == "email"
    end

    def is_phone
        self.type_of == "phone"
    end

    def self.activate_all user
        socials = user.user_socials
        socials.each do |social|
            social.activate
        end
    end

    def self.deactivate_all user
        socials = user.user_socials
        socials.each do |social|
            social.deactivate
        end
    end

    def activate
        self.update(active: true)
    end

    def deactivate
        self.update(active: false)
        # check the user record and removes/replaces socials from pre-compiled
        user = self.user
        if user.send(self.type_of) == self.identifier
            # if another user social exists move that data to user or use nil
            new_data = nil
            if new_user_social = UserSocial.where(user_id: self.user_id, type_of: self.type_of).first
                new_data = new_user_social.identifier
            end
            user.send("#{self.type_of}=" , new_data)
            user.save
        end
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

