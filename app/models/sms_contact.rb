class SmsContact < ActiveRecord::Base

    belongs_to :gift

    validates_with TextwordPhoneValidator, on: :create
    validates :phone, format: { with: VALID_PHONE_REGEX }

    def self.bulk_create contacts_hsh_ary, campaign_id
        return [] unless contacts_hsh_ary.kind_of?(Array)
        puts "Bulk saving to SmsContact"
        return_ary = contacts_hsh_ary.map do |contact_hsh|
            contact_hsh["campaign_id"] = campaign_id
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
# == Schema Information
#
# Table name: sms_contacts
#
#  id              :integer         not null, primary key
#  gift_id         :integer
#  subscribed_date :datetime
#  phone           :string(255)
#  service_id      :integer
#  service         :string(255)
#  textword        :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  campaign_id     :integer
#

