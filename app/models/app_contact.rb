class AppContact < ActiveRecord::Base

    has_many :friendships, dependent: :destroy
    has_many :users, through: :friendships

    before_validation :downcase_emails
    before_validation :extract_phone_digits

    validates :network, presence: true
    validates :network_id, presence: true
    validates_with UniqueNetworkValidator

private

    def extract_phone_digits
        if self.network == 'phone'
            phone_match = self.network_id.to_s.match(VALID_PHONE_REGEX)
            self.network_id  = phone_match[1] + phone_match[2] + phone_match[3]
        end
    end

    def downcase_emails
        if self.network == 'email' && self.network_id.kind_of?(String)
            self.network_id = self.network_id.downcase.strip
        end
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
