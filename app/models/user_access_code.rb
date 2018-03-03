class UserAccessCode < ActiveRecord::Base
    belongs_to :merchant
    belongs_to :affiliate

    def role=(user_access_role)
        self.role_id = user_access_role.id
    end
end
