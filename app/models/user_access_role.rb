class UserAccessRole < ActiveRecord::Base
    has_many :user_accesses,      as: :grants
    has_many :user_access_codes,  as: :codes

    # ------------

    include UserAccessHelper

    def level
        access_level(self.role)
    end
end
