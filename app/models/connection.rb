class Connection < ActiveRecord::Base

    belongs_to :friend, class_name: "User"
    belongs_to :contact, class_name: "UserSocial"

    validates :friend_id, presence: true
    validates :contact_id, presence: true
end
