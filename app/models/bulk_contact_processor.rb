class BulkContactProcessor

    def self.process(contacts: contacts, user_id: user_id)
        start_time_logger = Time.now
        # receive the normalized data
           # is there a user_social
        begin
            user = User.find(user_id)
        rescue
            return { "user" => "is invalid"}
        end
        ids = user.followers.map {|u| u.id }
                # is there a relationship # yes
                    # yes # do nothing  # no # create relationship
        remaining_contacts = []
        new_app_socials = contacts.map do |contact|
            user_social = if contact["network"] == "facebook"
                UserSocial.where(type_of: "facebook_id", identifier: contact["network_id"]).where.not(user_id: ids)
            else
                UserSocial.where(type_of: contact["network"], identifier: contact["network_id"]).where.not(user_id: ids)
            end
            if user_social.first.nil?
                remaining_contacts << contact
            end
            user_social
        end
        new_app_socials.flatten!

        new_app_socials.each do |social|
            Relationship.create(follower_id: social.user_id, followed_id: user.id)
        end
                # is there a relationship  # no
                        # if there another app_contact
                            # yes # is there a friendship
                                    # yes  # do nothing
                                    # no # create friendship
                            # no  # create app contact & friendship
        log_end_time start_time_logger, new_app_socials
    end

private

    def self.log_end_time start_time, ary
        end_time = ((Time.now - start_time) * 1000).round(1)
        inserts  = ary.count
        velocity = inserts != 0 ? end_time / inserts : "NaN"
        puts "BULK UPLOAD TIME = #{end_time}ms | contacts = #{inserts} | rate = #{velocity} ms/insert"
    end


end