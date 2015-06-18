class Friendship < ActiveRecord::Base

    validates :user_id, presence: true
    validates :app_contact_id, presence: true

#   -------------

    belongs_to :user
    belongs_to :app_contact

#   -------------

    def save args={}
        existing = Friendship.where(user_id: self.user_id, app_contact_id: self.app_contact_id).first
        if existing.nil?
            super
        else
            true
        end
    end
end
# == Schema Information
#
# Table name: friendships
#
#  id             :integer         not null, primary key
#  user_id        :integer
#  app_contact_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

