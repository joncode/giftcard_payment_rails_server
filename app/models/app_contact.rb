class AppContact < ActiveRecord::Base

    belongs_to :user

    validates_presence_of :network, :network_id, :user_id

    def self.upload(contacts: contacts, user: user)
        start_time_logger = Time.now
        current_user_id = user.id
        contact_ary     = generate_ary(contacts)
        contact_objs = []
        ActiveRecord::Base.transaction do
            contact_objs = contact_ary.map do |contact|
                AppContact.create(network: contact[:network], network_id: contact[:network_id], name: contact[:name], user_id: current_user_id)
            end
        end
        end_time = ((Time.now - start_time_logger) * 1000).round(1)
        inserts  = contact_objs.count
        velocity = end_time / inserts
        puts "BULK UPLOAD TIME = #{end_time}ms | contacts = #{inserts} | rate = #{velocity} ms/insert"
        contact_objs
    end

private

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
                contacts << create_contact_hsh(contact_id, name, iden, type_of)
            end
        end
        contacts
    end

    def self.fullname info_hsh
        "#{info_hsh['first_name']}" + " #{info_hsh['last_name']}"
    end

    def self.create_contact_hsh contact_id, name, identifier, type_of
        { _id: contact_id, name: name, network_id: identifier, network: type_of}
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
