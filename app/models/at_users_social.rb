class AtUsersSocial  < ActiveRecord::Base
    self.table_name = "at_users_socials"

    belongs_to :at_user
    belongs_to :social

	validates :social_id, :uniqueness => { scope: :at_user_id }

end



