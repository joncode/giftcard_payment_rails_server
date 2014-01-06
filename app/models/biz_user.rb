class BizUser < ActiveRecord::Base
    self.table_name = 'providers'
    has_many :sent,  as: :giver,  class_name: Gift
    has_many :debts, as: :owner

    def name
        "#{super} Staff"
    end

    def incur_debt amount
        debt = new_debt(amount)
        debt.save
        debt
    end

    def new_debt amount
        decimal_amount = BigDecimal(amount)
        service_fee    = decimal_amount * 0.15
        Debt.new(owner: self, amount: service_fee)
    end

    def get_photo
        return MERCHANT_DEFAULT_IMG if image.blank?
        image
    end

end
# == Schema Information
#
# Table name: providers
#
#  id             :integer         not null, primary key
#  name           :string(255)     not null
#  zinger         :string(255)
#  description    :text
#  address        :string(255)
#  address_2      :string(255)
#  city           :string(32)
#  state          :string(2)
#  zip            :string(16)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  phone          :string(255)
#  email          :string(255)
#  twitter        :string(255)
#  facebook       :string(255)
#  website        :string(255)
#  sales_tax      :string(255)
#  active         :boolean         default(TRUE)
#  latitude       :float
#  longitude      :float
#  foursquare_id  :string(255)
#  rate           :decimal(, )
#  menu_is_live   :boolean         default(FALSE)
#  brand_id       :integer
#  building_id    :integer
#  sd_location_id :integer
#  token          :string(255)
#  tools          :boolean         default(FALSE)
#  image          :string(255)
#  merchant_id    :integer
#  live           :boolean         default(FALSE)
#  paused         :boolean         default(TRUE)
#

