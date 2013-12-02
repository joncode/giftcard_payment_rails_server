class PeopleFinder

    def self.find hash
        new_hsh = self.sanitize hash
        self.search_ids new_hsh
    end

private

    def self.sanitize hsh
        type_ofs = hsh.keys
        new_hsh = {}
        hsh.each do |key, value|
            type_of = key.to_s
            type_of = "email" if type_of.match(/email/)
            type_of = "phone" if type_of.match(/phone/)
            new_hsh[type_of] = value
        end
        return new_hsh
    end

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

    def self.search_db(type_of, identifier)
        user_social = UserSocial.where(type_of: type_of, identifier: identifier).first
        if user_social
            user_social.user
        else
            nil
        end
    end

end



