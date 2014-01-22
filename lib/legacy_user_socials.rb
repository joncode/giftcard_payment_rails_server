module LegacyUserSocials

    def create_user_socials
        users = User.all
        users.each do |user|
            # take email , phone , fb , twitter
            # look thru US db for those records
            # if not , create a US record
            [:email, :phone, :facebook_id, :twitter].each do |id|
                obj = user.send(id)
                social = UserSocial.create(user_id: user.id, type_of: id.to_s, identifier: obj)
            end
        end
    end

end