class Connection < ActiveRecord::Base

    belongs_to :friend, class_name: "User"
    belongs_to :contact, class_name: "UserSocial"

    validates :friend_id, presence: true
    validates :contact_id, presence: true
end
# == Schema Information
#
# Table name: connections
#
#  id         :integer         not null, primary key
#  friend_id  :integer
#  contact_id :integer
#  created_at :datetime
#  updated_at :datetime
#

