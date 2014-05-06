class BulkContact < ActiveRecord::Base

    after_save :process_bulk_contacts

    def self.upload(data: data, user_id: user_id)
        start_time_logger = Time.now
        hsh_str = data.to_json
        if !Rails.env.production?
            output = create(data: hsh_str, user_id: user_id)
        end
        end_time = ((Time.now - start_time_logger) * 1000).round(1)
        puts "BULK DUMP TIME = #{end_time}ms"
        output
    end

    def parsed_data
        start_time_logger = Time.now
        dat = JSON.parse data
        end_time = ((Time.now - start_time_logger) * 1000).round(1)
        puts "BULK PARSE TIME = #{end_time}ms"
        dat
    end

    def normalized_data
        data_hsh = JSON.parse data
        if data_hsh.kind_of? Hash
            generate_ary(data_hsh)
        else
            data_hsh.map do |c|
                hsh = { name: fullname(c), network_id: c["network_id"], network: c["network"], handle: c["handle"], birthday: c["birthday"]}.stringify_keys
                format_phone_and_email hsh
            end
        end
    end

private

    def process_bulk_contacts
        if !Rails.env.production?
            Resque.enqueue(BulkContactJob)
        end
    end

    def generate_ary contact_hsh
        contacts = []
        each_contact_hsh = []
        contact_hsh.keys.each do |contact_id|
            info_hsh   = contact_hsh[contact_id]
            name       = fullname(info_hsh)
            pre_concat_contacts = ["email", "phone", "twitter", "facebook"].map do |type_of|
                get_identifiers(contact_id, name, info_hsh, type_of)
            end
            each_contact_hsh << pre_concat_contacts.flatten
        end
        contacts = each_contact_hsh.flatten
    end

    def get_identifiers contact_id, name, info_hsh, type_of
        contacts = []
        if info_hsh.keys.include? type_of
            identifiers = info_hsh[type_of]
            identifiers.each do |iden|
                contacts << create_contact_hsh(name, iden, type_of)
            end
        end
        contacts
    end

    def fullname info_hsh
        if info_hsh['first_name'].present?
            "#{info_hsh['first_name']}" + " #{info_hsh['last_name']}"
        elsif info_hsh['name'].present?
            info_hsh['name']
        end
    end

    def create_contact_hsh name, identifier, type_of
        hsh = { name: name, network_id: identifier, network: type_of}.stringify_keys
        format_phone_and_email hsh
    end

    def format_phone_and_email contact
        if contact["network"] == 'email'
            contact["network_id"] = contact["network_id"].downcase
        elsif contact["network"] == 'phone'
            phone_match = contact["network_id"].to_s.match(VALID_PHONE_REGEX)
            if phone_match.present?
                contact["network_id"]  = phone_match[1] + phone_match[2] + phone_match[3]
            else
                contact["network_id"].gsub!(")-", '')
                phone_match = contact["network_id"].to_s.match(VALID_PHONE_REGEX)
                if phone_match.present?
                    contact["network_id"]  = phone_match[1] + phone_match[2] + phone_match[3]
                end
            end
        end
        contact
    end
end
