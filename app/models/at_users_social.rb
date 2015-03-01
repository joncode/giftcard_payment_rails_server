class AtUsersSocial  < ActiveRecord::Base
    self.table_name = "at_users_socials"

    belongs_to :at_user
    belongs_to :social

	validates :social_id, :uniqueness => { scope: :at_user_id }

end



# == Schema Information
#
# Table name: at_users_socials
#
#  id         :integer         not null, primary key
#  at_user_id :integer
#  social_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

