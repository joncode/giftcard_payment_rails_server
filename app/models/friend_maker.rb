class FriendMaker

    def self.user_create(user_id)
        start_time_logger = Time.now
        begin
            user = User.find(user_id)
        rescue
            return { "user" => "is invalid"}
        end
        ids     = user.followed_users.map {|u| u.id }
        socials = user.user_socials
        new_app_contacts = []
        new_app_contacts = socials.map do |social|
            if social.type_of == "facebook_id"
                AppContact.where(network: "facebook", network_id: social.identifier).where.not(user_id: ids)
            else
                AppContact.where(network: social.type_of, network_id: social.identifier).where.not(user_id: ids)
            end
        end
        new_app_contacts.flatten!

        new_app_contacts.each do |contact|
            Relationship.create(follower_id: user.id, followed_id: contact.user_id)
        end

        log_end_time start_time_logger, new_app_contacts
        #     # all those users will now have ItsOnMe friends
        #         send_friend_push to :followed_id
        #         get_friends == app_contact_user.followers
    end

    def self.contact_create(user_id)
        start_time_logger = Time.now
        begin
            user = User.find(user_id)
        rescue
            return { "user" => "is invalid"}
        end
        ids      = user.followers.map {|u| u.id }
        contacts = user.app_contacts
        new_app_socials = []
        new_app_socials = contacts.map do |contact|
            if contact.network == "facebook"
                UserSocial.where(type_of: "facebook_id", identifier: contact.network_id).where.not(user_id: ids)
            else
                UserSocial.where(type_of: contact.network, identifier: contact.network_id).where.not(user_id: ids)
            end
        end
        new_app_socials.flatten!

        new_app_socials.each do |social|
            Relationship.create(follower_id: social.user_id, followed_id: user.id)
        end
        log_end_time start_time_logger, new_app_socials
        #
        #         send_number_of_friend_push to :followed_id
        #         get_friends == app_contact_user.followers
    end

private

    def self.log_end_time start_time, ary
        end_time = ((Time.now - start_time) * 1000).round(1)
        inserts  = ary.count
        velocity = inserts != 0 ? end_time / inserts : "NaN"
        puts "BULK UPLOAD TIME = #{end_time}ms | contacts = #{inserts} | rate = #{velocity} ms/insert"
    end
end



# API

#  user get contacts and make relationships
#  contacts get users and make relationship