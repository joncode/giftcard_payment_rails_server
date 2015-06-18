class AdminUser < ActiveRecord::Base
    self.table_name = "at_users"

#   -------------

    def giver
        AdminGiver.find(self.id)
    end

#   -------------

    def name
        if self.last_name.blank?
          "#{self.first_name}"
        else
          "#{self.first_name} #{self.last_name}"
        end
    end

end

# == Schema Information
#
# Table name: at_users
#
#  id                     :integer         not null, primary key
#  first_name             :string(255)
#  last_name              :string(255)
#  email                  :string(255)
#  phone                  :string(255)
#  sex                    :string(255)
#  birthday               :date
#  password_digest        :string(255)
#  remember_token         :string(255)     not null
#  admin                  :boolean         default(FALSE)
#  code                   :string(255)
#  confirm                :integer         default(0)
#  reset_token_sent_at    :datetime
#  reset_token            :string(255)
#  active                 :boolean         default(TRUE)
#  db_user_id             :integer
#  address                :string(255)
#  city                   :string(255)
#  state                  :string(2)
#  zip                    :string(16)
#  photo                  :string(255)
#  min_photo              :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  last_login             :datetime
#  time_zone              :integer         default(0)
#  acct                   :boolean         default(FALSE)
#  encrypted_password     :string(255)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#

