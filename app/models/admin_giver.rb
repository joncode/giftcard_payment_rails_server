class AdminGiver < ActiveRecord::Base
    self.table_name = "at_users"
    include ShortenPhotoUrlHelper

#   -------------

    has_many :sent,  as: :giver,  class_name: Gift
    has_many :debts, as: :owner
    has_many :protos, as: :giver, class_name: Proto

#   -------------

        ####### Gift Giver Ducktype
    def name
        "#{SERVICE_NAME} Staff"
    end

    def get_photo
        "http://res.cloudinary.com/drinkboard/image/upload/v1389818563/IOM-icon_round_bzokjj.png"
    end

    def short_image_url
        shorten_photo_url self.get_photo
    end
        ####### Debt Ducktype as Owner
    def incur_debt amount
        debt = new_debt(amount)
        debt.save
        debt
    end

    def new_debt amount
        decimal_amount = BigDecimal(amount)
        Debt.new(owner: self, amount: decimal_amount, total: decimal_amount)
    end
end# == Schema Information
#
# Table name: users
#
#  id                  :integer         not null, primary key
#  first_name          :string(255)
#  last_name           :string(255)
#  email               :string(255)
#  phone               :string(255)
#  sex                 :string(255)
#  birthday            :date
#  password_digest     :string(255)
#  remember_token      :string(255)     not null
#  admin               :boolean         default(FALSE)
#  code                :string(255)
#  confirm             :integer         default(0)
#  reset_token_sent_at :datetime
#  reset_token         :string(255)
#  active              :boolean         default(TRUE)
#  db_user_id          :integer
#  address             :string(255)
#  city                :string(255)
#  state               :string(2)
#  zip                 :string(16)
#  photo               :string(255)
#  min_photo           :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  last_login          :datetime
#  time_zone           :integer         default(0)
#  acct                :boolean         default(FALSE)
#

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

