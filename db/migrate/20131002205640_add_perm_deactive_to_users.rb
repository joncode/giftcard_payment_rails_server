class AddPermDeactiveToUsers < ActiveRecord::Migration
    def up
        add_column :users, :perm_deactive, :boolean, default: false
        add_index :users, [:active, :perm_deactive]

        set_legacy_data
    end

    def down
        undo_legacy_data

        remove_index :users,[:active, :perm_deactive]
        remove_column :users, :perm_deactive
    end

    def set_legacy_data
        user_social_from_legacy
        correct_deactivated_users
    end

    def undo_legacy_data
        undo_perm_deactives
        UserSocial.delete_all
    end

    def undo_perm_deactives
        users = User.where(perm_deactive: true)
        users.each do |u|
            u.last_name = u.name
            u.first_name = "De-activated[app]"
            u.active = false
            u.save
        end
    end

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
end
