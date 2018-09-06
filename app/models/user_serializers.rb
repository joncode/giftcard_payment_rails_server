#require 'benchmark'

module UserSerializers

    def serialize(token=false)
        usr_hash  = self.serializable_hash only: ["first_name", "last_name" , "address" , "city" , "state" , "zip", "birthday", "sex", "email", "phone", "facebook_id", "twitter"]
        usr_hash["photo"]   = self.get_photo
        usr_hash["user_id"] = self.id.to_s
        usr_hash.keep_if {|k, v| !v.nil? }
        usr_hash["remember_token"] = self.remember_token if token
        usr_hash
    end

    def get_serialize
        usr_hash  = self.serializable_hash only: ["first_name", "last_name"]
        usr_hash["photo"]   = self.get_photo
        usr_hash["user_id"] = self.id
        usr_hash
    end

    def get_other_serialize
        usr_hash  = self.serializable_hash only: ["first_name", "last_name", "city", "state", "zip", "sex"]
        usr_hash["photo"]   = self.get_photo
        usr_hash["user_id"] = self.id
        usr_hash
    end

    def client_serialize
        usr_hash  = self.serializable_hash only: ["first_name", "last_name"]
        usr_hash["photo"]   = self.get_photo
        usr_hash["user_id"] = self.id
        remove_nils(usr_hash)
    end

    def login_client_serialize
        usr_hash  = self.serializable_hash only: ["first_name", "last_name", "birthday", "zip", "sex"]
        usr_hash["photo"]   = self.get_photo
        usr_hash["user_id"] = self.id

        # Set default primary UserSocials for the user if they don't have any yet
        UserSocial.ensure_primaries(self.id)

        ids = ["email", "phone", "facebook_id", "twitter"].each do |id|
            us = self.user_socials.where(type_of: id)
            if us.count > 0
                if id == 'facebook_id'
                    net_id = 'facebook'
                else
                    net_id = id
                end
                usr_hash[net_id] = []
                us.each do |social|
                    if social.status == 'live'
                        usr_hash[net_id] << { "_id" => social.id,
                            "value" => social.identifier,
                            'status' => social.status }
                    else
                        usr_hash[net_id] << { "_id" => social.id,
                            "value" => social.identifier,
                            'status' => social.status,
                            'msg' => social.msg }
                    end
                end
            end
        end
        usr_hash["token"] = self.remember_token
        usr_hash
    end

    def profile_serialize
        usr_hash  = self.serializable_hash only: ["first_name", "last_name", "birthday", "zip", "sex"]
        usr_hash["photo"]   = self.get_photo
        usr_hash["user_id"] = self.id
        ids = ["email", "phone", "facebook_id", "twitter"].each do |id|
            us = self.user_socials.where(type_of: id)
            if us.count > 0
                usr_hash[id] = []
                us.each do |social|
                    usr_hash[id] << social.identifier
                end
            end
        end
        usr_hash
    end

    def profile_with_ids_serialize
        usr_hash  = self.serializable_hash only: ["first_name", "last_name", "birthday", "zip", "sex"]
        usr_hash["photo"]   = self.get_photo
        usr_hash["user_id"] = self.id
        us = self.user_socials
        ids = ["email", "phone", "facebook_id", "twitter"]
        us.each do |social|
            if ids.include? social.type_of
                usr_hash[social.type_of] = [] unless usr_hash[social.type_of].present?
                usr_hash[social.type_of] << { "_id" => social.id, "value" => social.identifier }
            end
        end
        usr_hash
    end

    def create_serialize
        usr_hash  = self.serializable_hash only: ["first_name", "last_name", "birthday", "email", "zip", "phone", "facebook_id", "twitter"]
        usr_hash["photo"]   = self.get_photo
        usr_hash["user_id"] = self.id
        usr_hash["token"] = self.remember_token
        usr_hash
    end

    def update_serialize
        usr_hash  = self.serializable_hash only: ["first_name", "last_name", "birthday", "email", "zip", "phone", "facebook_id", "twitter", "sex"]
        usr_hash["photo"]   = self.get_photo
        usr_hash["user_id"] = self.id
        usr_hash
    end

    def admt_serialize
        usr_hash  = self.serializable_hash only: ["first_name", "last_name" ,  "zip", "birthday", "email", "phone", "created_at"]
        usr_hash["photo"]   = self.get_photo
        usr_hash["user_id"] = self.id
        usr_hash["fb"]      = self.facebook_id_exists? ? "Yes" : "No"
        usr_hash["twitter"] = self.twitter_exists? ? "Yes" : "No"
        if self.first_name == "De-activated[app]"
            usr_hash["active"]  = 2
        else
            usr_hash["active"]  = self.active ? 1 : 0
        end
        usr_hash.keep_if {|k, v| !v.nil? }
        usr_hash
    end
end