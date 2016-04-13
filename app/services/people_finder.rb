class PeopleFinder

    def self.find hsh
        new_hsh = self.sanitize hsh
        self.search_ids new_hsh
    end

    def self.sanitize hsh
        new_hsh = {}
        hsh.each do |key, value|
            type_of = key.to_s
            type_of = "email" if type_of.match(/email/)
            type_of = "phone" if type_of.match(/phone/)
            new_hsh[type_of] = value
        end
        return new_hsh
    end

    def self.search_db(type_of, identifier)
        user_social = UserSocial.where(type_of: type_of, identifier: identifier).first
        if user_social
            user_social.user
        else
            nil
        end
    end

    def self.search_socials(network, network_id)
        Social.where(network: type_of, network_id: identifier).first
    end

private

    def self.search_ids new_hsh
        type_of_ary = [ "facebook_id", "email", "phone", "twitter"]
        user = self.find_user_with(type_of_ary[0], new_hsh)
        user = self.find_user_with(type_of_ary[1], new_hsh) if user.nil?
        user = self.find_user_with(type_of_ary[2], new_hsh) if user.nil?
        user = self.find_user_with(type_of_ary[3], new_hsh) if user.nil?
        return user || false
    end

    def self.find_user_with type_of, new_hsh
        if new_hsh[type_of]
            if user = self.search_db(type_of, new_hsh[type_of])
                return user
            end
        end
        return nil
    end


end



