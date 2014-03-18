class SmsContact < ActiveRecord::Base

    belongs_to :gift

    validates_with TextwordPhoneValidator, on: :create
    validates :phone, format: { with: VALID_PHONE_REGEX }

    def self.bulk_create contacts_hsh
        puts "Bulk saving to SmsContact"
        contacts_hsh.map do |contact_hsh|
            r = SmsContact.new(contact_hsh)
            r.save if r.valid?
            if r.id.nil?
                puts r.inspect
                puts r.errors.messages
            end
            r
        end
    end

private

    # def init_from_hsh contact
    #     sms = SmsContact.new
    #     sms.phone           = contact["phone"]
    #     sms.service         = contact["service"]
    #     sms.service_id      = contact["service_id"]
    #     sms.textword        = contact["textword"]
    #     sms.subscribed_date = contact["subscribed_date"]
    #     sms
    # end
end
