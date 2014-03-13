class FriendMaker

    def self.create(user_id)
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
    end

end


#     # get your followed_id's
#         ids = Relationship.where(follower_id: current_user.id).map &:id
#         ids = current_user.followed_users.map &:id

#     # get your user_socials
#         socials = current_user.user_socials

#     # for each user social look for app_contacts that match

#         app_contacts = AppContact.where(network: social.type_of, network_id: social.identifier).where.not(user_id: [ids])
#             gimme all the contacts that == that social that is not already a relationship to current_user

#     # for each app_contact make a relationship where app_contact.user is the :followed_user
#         Relationship.create(follower_id: current_user.id, followed_id: app_contact.user_id)

#     # all those users will now have ItsOnMe friends
#         send_friend_push to :followed_id
#         get_friends == app_contact_user.followers

# What is the FriendMaker API ?

#     create(user_id)