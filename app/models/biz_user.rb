class BizUser < ActiveRecord::Base
    include ShortenPhotoUrlHelper

    self.table_name = 'providers'

    has_many :sent,  as: :giver,  class_name: Gift
    has_many :protos, as: :giver, class_name: Proto
    has_many :debts, as: :owner

        ####### Gift Giver Ducktype
    def name
        "#{super} Staff"
    end

    def get_photo
        return MERCHANT_DEFAULT_IMG if image.blank?
        image
    end

    def short_image_url
        shorten_photo_url self.get_photo
    end

    # hidden giver ducktype methods
        # biz_user_obj.id    as giver_id   - provider_id
        # biz_user_obj.class as giver_type - BizUser class

        ####### Debt Ducktype as Owner
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

end
# == Schema Information
#
# Table name: providers
#
#  id              :integer         not null, primary key
#  name            :string(255)     not null
#  zinger          :string(255)
#  description     :text
#  address         :string(255)
#  city            :string(32)
#  state           :string(2)
#  zip             :string(16)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  phone           :string(255)
#  sales_tax       :string(255)
#  active          :boolean         default(TRUE)
#  latitude        :float
#  longitude       :float
#  rate            :decimal(, )
#  menu_is_live    :boolean         default(FALSE)
#  brand_id        :integer
#  building_id     :integer
#  token           :string(255)
#  tools           :boolean         default(FALSE)
#  image           :string(255)
#  merchant_id     :integer
#  live            :boolean         default(FALSE)
#  paused          :boolean         default(TRUE)
#  pos_merchant_id :string(255)
#  region_id       :integer
#  r_sys           :integer         default(2)
#  photo_l         :string(255)
#  payment_plan    :integer         default(0)
#

