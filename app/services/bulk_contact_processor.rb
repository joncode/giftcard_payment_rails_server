class BulkContactProcessor

    def self.process(contacts: contacts_in, user_id: user_id_in)
        start_time_logger = Time.now
        new_relationship = false
        # receive the normalized data
           # is there a user_social
        begin
            user = User.find(user_id)
        rescue
            return { "user" => "is invalid"}
        end
        ids = user.followers.map {|u| u.id }
                # is there a user_social # yes
                    # relationship ? yes # do nothing  # no # create relationship
        remaining_contacts = []
        new_app_socials = contacts.map do |contact|
            user_social = if contact["network"] == "facebook"
                UserSocial.where(type_of: "facebook_id", identifier: contact["network_id"]).first
            else
                UserSocial.where(type_of: contact["network"], identifier: contact["network_id"]).first
            end
            if user_social.nil?
                remaining_contacts << contact
                nil
            else
                if [ids].include?(user_social.user_id)
                    nil
                else
                    user_social
                end
            end
        end
        new_app_socials.compact!

        new_app_socials.each do |social|
            r = Relationship.create(follower_id: social.user_id, followed_id: user.id)
            puts "generating a relationship ? #{r.id}"
            if r.id.present?
                new_relationship = true
            end
        end
                # is there a user_social  # no
                        # if there another app_contact
                            # yes # is there a friendship
                                    # yes  # do nothing
                                    # no # create friendship
                            # no  # create app contact & friendship
        friend_ids = user.app_contacts.map(&:id)
        remaining_contacts.each do |contact|
            app_contact = AppContact.find_or_create_by(network: contact["network"], network_id: contact["network_id"]) do |app_c|
                app_c.name     = contact["name"]
                app_c.birthday = contact["birthday"]
                app_c.handle   = contact["handle"]
            end
            Friendship.create(user_id: user.id, app_contact_id: app_contact.id)
        end
        log_end_time start_time_logger, new_app_socials
        return new_relationship
    end

private

    def self.log_end_time start_time, ary
        end_time = ((Time.now - start_time) * 1000).round(1)
        inserts  = ary.count
        velocity = inserts != 0 ? end_time / inserts : "NaN"
        puts "BULK UPLOAD TIME = #{end_time}ms | contacts = #{inserts} | rate = #{velocity} ms/insert"
    end


end