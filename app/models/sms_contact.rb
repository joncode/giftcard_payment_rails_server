class SmsContact < ActiveRecord::Base

    belongs_to :gift

    validates_with TextwordPhoneValidator, on: :create
    validates :phone, format: { with: VALID_PHONE_REGEX }

    def self.bulk_create contacts_hsh_ary
        return [] unless contacts_hsh_ary.kind_of?(Array)
        puts "Bulk saving to SmsContact"
        return_ary = contacts_hsh_ary.map do |contact_hsh|
            r = SmsContact.new(contact_hsh)
            if r.valid?
                r.save
                r
            else
                nil
            end
        end
        return return_ary.compact
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
