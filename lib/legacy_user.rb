module LegacyUser


    def check_users
        total = 0
        pdus = User.unscoped.where(perm_deactive: true).where(active: false)
        pdus.each {|u| puts u.inspect }

        us = User.unscoped.where(perm_deactive: false).where(active: true)

        us.each do |u|
            puts "user ID = #{u.id}"
            if u.email.present?
                "email"
                confirm_social_save u.email
                total += 1
            end
            if u.phone.present?
                "phone"
                confirm_social_save u.phone
                total += 1
            end
            if u.twitter.present?
                "twitter"
                confirm_social_save u.twitter
                total += 1
            end
            if u.facebook_id.present?
                "facebook_id"
                confirm_social_save u.facebook_id
                total += 1
            end
        end

        dus = User.unscoped.where(perm_deactive: false).where(active: false)
        totalUs = UserSocial.where(active: true).count
        totalUs = totalUs - count_users(dus)
        puts "deactivated Users #{dus.count}"
        puts "Premanent Deactives #{pdus.count}"
        puts "Active Users = #{us.count}"
        puts "User Socials needed = #{total} | saved #{totalUs}"
        total_users = User.unscoped

        counted_user = pdus.count + us.count + dus.count
        puts "total users #{total_users.count} - counted = #{counted_user}"
    end

    def confirm_social_save identifier
        if uss = UserSocial.find_by_identifier(identifier)
            puts "true"
        else
            puts "false--------------------------------------------------------------------------"
        end
    end

    def count_users(us)
        total = 0
        us.each do |u|
            puts "user ID = #{u.id}"
            if u.email.present?
                "email"
                total += 1
            end
            if u.phone.present?
                "phone"
                total += 1
            end
            if u.twitter.present?
                "twitter"
                total += 1
            end
            if u.facebook_id.present?
                "facebook_id"
                total += 1
            end
        end
        total
    end

end