module UserAccessHelper

    def access_level(role)
        [:employee, :manager, :admin].index(role.to_s.to_sym) || -1
    end

end
