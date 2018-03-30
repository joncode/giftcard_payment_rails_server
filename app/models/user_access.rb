class UserAccess < ActiveRecord::Base
    belongs_to :user
    belongs_to :owner, polymorphic: true

    def role
        return nil  if self.role_id.nil?
        ::UserAccessRole.find(self.role_id)
    end

    def role=(user_access_role)
        self.role_id = user_access_role.id
    end


    # ------------

    include UserAccessHelper

    def level
        access_level(self.role.role)
    end

    # Expose UserAccess.level()
    class << self
        include UserAccessHelper

        def level(role)
            access_level(role)
        end
    end


    # ------------

    def self.grant_for(user_id:, role:nil, role_id:nil, owner:nil, owner_id:nil, owner_type:nil)
        # Role -> role_id
        if role.present?
            if role.is_a? UserAccessRole
                role_id = role.id
            elsif role.is_a? Symbol
                role_id = UserAccessRole.where(active: true).where(role: role.to_s.downcase).first.id  rescue nil
            else
                raise ArgumentError, "Expected role of type UserAccessRole or Symbol, got #{role.class}"
            end
        end
        raise ArgumentError, "Role not found"  if role_id.nil?

        # Owner -> id/type
        unless owner.nil?
            owner_type = nil
            owner_type = :merchant  if owner.is_a? Merchant
            owner_type = :affiliate if owner.is_a? Affiliate
            owner_id   = owner.id  rescue nil
            if owner_type.nil?
                raise ArgumentError, "Invalid owner specified. Must be instance of Merchant or Affilaite. Got: #{owner.class}"
            end
            if owner_id.nil?
                raise ArgumentError, "No owner_id specified"
            end
        end

        owner_type = owner_type.to_s.capitalize
        unless ["Merchant","Affiliate"].include? owner_type
            raise ArgumentError, "Invalid owner type. Must be Merchant or Affiliate"
        end

        grant = self.new
        grant.user_id    = user_id
        grant.role_id    = role_id
        grant.owner_id   = owner_id
        grant.owner_type = owner_type
        grant
    end


    def deactivate!
        self.active = false
        self.save
    end

end