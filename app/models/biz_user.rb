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
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

