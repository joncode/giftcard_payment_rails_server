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

            # i wanna know if there are any app_contacts that match my user_social
        app_contacts = socials.map do |social|
            if social.type_of == "facebook_id"
                AppContact.where(network: "facebook", network_id: social.identifier).first
            else
                AppContact.where(network: social.type_of, network_id: social.identifier).first
            end
        end
            # get the friends of those contacts
        friend_users = app_contacts.compact.map do |ac|
            ac.users
        end

            # make relationships out of them
        friend_users.flatten.each do |f_user|
            Relationship.create(follower_id: user.id, followed_id: f_user.id)
        end

        log_end_time start_time_logger, friend_users
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