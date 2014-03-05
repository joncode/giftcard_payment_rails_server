class ContactUpload

    attr_reader :ary, :user, :socials

    def initialize contact_ary, current_user
        @user    = current_user
        @ary     = generate_ary(contact_ary)
        @socials = user_socials
    end

    def user_socials
        ary.map do |contact|
            UserSocial.where(type_of: contact[:type_of], identifier: contact[:identifier]).first_or_create
        end
    end

    def connections
        uss = socials
        contacts = uss.select { |us| us.user_id == nil }
        contacts.map do |contact|
            Connection.create(friend_id: @user.id, contact_id: contact.id)
        end
    end

    def relationships
        uss = socials
        contacts = uss.select { |us| us.user_id != nil }
        contacts.map do |contact|
            Relationship.create(follower_id: @user.id, followed_id: contact.user_id)
        end
    end

private

    def generate_ary contact_ary
        contacts = []
        each_contact_ary = []
        contact_ary.each do |contact|
            contact_id = contact.keys.first
            info_hsh   = contact[contact_id]
            name       = fullname(info_hsh)
            pre_concat_contacts = ["email", "phone", "twitter", "facebook"].map do |type_of|
                get_identifiers(contact_id, name, info_hsh, type_of)
            end
            each_contact_ary << pre_concat_contacts.flatten
        end
        contacts = each_contact_ary.flatten
    end

    def get_identifiers contact_id, name, info_hsh, type_of
        contacts = []
        if info_hsh.keys.include? type_of
            identifiers = info_hsh[type_of]
            identifiers.each do |iden|
                contacts << create_contact_hsh(contact_id, name, iden, type_of)
            end
        end
        contacts
    end

    def fullname info_hsh
        "#{info_hsh['first_name']}" + " #{info_hsh['last_name']}"
    end

    def create_contact_hsh contact_id, name, identifier, type_of
        { _id: contact_id, name: name, identifier: identifier, type_of: type_of}
    end
end