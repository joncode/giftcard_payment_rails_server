module LegacyUser

    def user_social_from_legacy

        # make sure the MailchimpList is turned off

        users = User.unscoped
        users.each do |user|
            UserSocial.create(user_id: user.id, type_of: "email", identifier: user.email) if user.email.present?
            UserSocial.create(user_id: user.id, type_of: "phone", identifier: user.phone) if user.phone.present?
            UserSocial.create(user_id: user.id, type_of: "facebook_id", identifier: user.facebook_id) if user.facebook_id.present?
            UserSocial.create(user_id: user.id, type_of: "twitter", identifier: user.twitter) if user.twitter.present?
        end
    end

    def correct_deactivated_users
        # get users with first_name "De-activated[app]"
        permanently_deactivated_users = User.unscoped.where(active: false).where(first_name: "De-activated[app]")
        # delete fields
        permanently_deactivated_users.each do |pdu|
            pdu.first_name, pdu.last_name  = split_name(pdu.last_name)
            pdu.permanently_deactivate
            puts pdu.inspect
        end
        nil
    end

    def split_name name
        name_ary    = name.split(' ')
        last_name   = name_ary.pop
        first_name  = if name_ary.kind_of? String
            name_ary
        else
            name_ary.join(' ')
        end
        return first_name, last_name
    end

    def check_users

        pdus = User.unscoped.where(perm_deactive: true).where(active: false)
        pdus.each {|u| puts u.inspect }

        us = User.unscoped.where(perm_deactive: false).where(active: true)

        us.each do |u|
            puts "user ID = #{u.id}"
            if u.email.present?
                "email"
                confirm_social_save u.email
            end
            if u.phone.present?
                "phone"
                confirm_social_save u.email
            end
            if u.twitter.present?
                "twitter"
                confirm_social_save u.email
            end
            if u.facebook_id.present?
                "facebook_id"
                confirm_social_save u.email
            end
        end

        dus = User.unscoped.where(perm_deactive: false).where(active: false)
        puts "deactivated Users #{dus.count}"
        puts "Premanent Deactives #{pdus.count}"
        puts "Active Users = #{us.count}"
        total_users = User.unscoped

        counted_user = pdus.count + us.count + dus.count
        puts "total users #{total_users.count} - counted = #{counted_user}"
    end

    def confirm_social_save identifier
        if uss = UserSocial.find_by_identifier(identifier)
            puts "true"
        else
            puts "false"
        end
    end



end