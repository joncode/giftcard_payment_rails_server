class UserAccessCode < ActiveRecord::Base
    belongs_to :merchant
    belongs_to :affiliate


    def role
        return nil  if self.role_id.nil?
        ::UserAccessRole.find(self.role_id)
    end

    def role=(user_access_role)
        self.role_id = user_access_role.id
    end
end
