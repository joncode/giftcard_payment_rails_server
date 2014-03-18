class Friendship < ActiveRecord::Base

    belongs_to :user
    belongs_to :app_contact

    validates :user_id, presence: true
    validates :app_contact_id, presence: true

    def save args={}
        existing = Friendship.where(user_id: self.user_id, app_contact_id: self.app_contact_id).first
        if existing.nil?
            super
        else
            true
        end
    end
end
