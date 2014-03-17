class AppContact < ActiveRecord::Base

    belongs_to :user

    before_save :downcase_emails
    before_save :extract_phone_digits

    validates :network, presence: true
    validates :network_id, presence: true
    validates :user_id, presence: true

    def self.upload(data: data, user_id: user_id)
        start_time_logger = Time.now

        # bulk save app contacts

        end_time = ((Time.now - start_time_logger) * 1000).round(1)
        inserts  = contact_objs.count
        velocity = end_time / inserts
        puts "BULK UPLOAD TIME = #{end_time}ms | contacts = #{inserts} | rate = #{velocity} ms/insert"

            # is this in the correct place ??
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
