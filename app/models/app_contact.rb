class AppContact < ActiveRecord::Base

    belongs_to :user

    before_save :downcase_emails
    before_save :extract_phone_digits

    validates :network, presence: true
    validates :network_id, presence: true
    validates :user_id, presence: true

    def self.upload(contacts: nil, user: user, proxy_contacts: nil)
        start_time_logger = Time.now
        current_user_id = user.id
        if proxy_contacts.nil?
            contact_ary     = generate_ary(contacts)
        elsif contacts.nil?
            contact_ary     = proxy_contacts.map do |c|
                { name: c["name"], network_id: c["network_id"], network: c["network"], handle: c["handle"], birthday: c["birthday"]}
            end
        end


        contact_objs = []
        ActiveRecord::Base.transaction do
            contact_objs = contact_ary.map do |contact|
                contact[:user_id] = current_user_id
                #AppContact.create(network: contact[:network], network_id: contact[:network_id], name: contact[:name], user_id: current_user_id)
                AppContact.create(contact)
            end
        end
        end_time = ((Time.now - start_time_logger) * 1000).round(1)
        inserts  = contact_objs.count
        velocity = end_time / inserts
        puts "BULK UPLOAD TIME = #{end_time}ms | contacts = #{inserts} | rate = #{velocity} ms/insert"
        if contact_objs.count > 0
            Resque.enqueue(FriendPushJob, user.id, 2)
        end
        contact_objs
    end

private

    def extract_phone_digits
        if self.network == 'phone'
            phone_match = self.network_id.to_s.match(VALID_PHONE_REGEX)
            self.network_id  = phone_match[1] + phone_match[2] + phone_match[3]
        end
    end

    def downcase_emails
        if self.network == 'email'
            self.network_id = self.network_id.downcase
        end
    end

    def self.generate_ary contact_ary
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

    def self.get_identifiers contact_id, name, info_hsh, type_of
        contacts = []
        if info_hsh.keys.include? type_of
            identifiers = info_hsh[type_of]
            identifiers.each do |iden|
                contacts << create_contact_hsh(name, iden, type_of)
            end
        end
        contacts
    end

    def self.fullname info_hsh
        "#{info_hsh['first_name']}" + " #{info_hsh['last_name']}"
    end

    def self.create_contact_hsh name, identifier, type_of
        { name: name, network_id: identifier, network: type_of}
    end
end

  # create_table "app_contacts", force: true do |t|
  #   t.integer  "user_id"
  #   t.string   "network"
  #   t.string   "network_id"
  #   t.string   "name"
  #   t.date     "birthday"
  #   t.string   "handle"
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  # end
