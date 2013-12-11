class Sale < ActiveRecord::Base

    belongs_to :provider
    belongs_to :giver, class_name: "User"
    belongs_to :card

    has_one :gift, as: :payable

    validates_presence_of :giver_id, :card_id, :resp_code

    def self.charge_card cc_hsh
            # pull off and charge the credit card
            
        payment_hsh = {}
        credit_card_data_keys = ["number", "month_year", "first_name", "last_name", "amount"]
        credit_card_data_keys << "unique_id" if cc_hsh["unique_id"]
        credit_card_data_keys.each do |cc_data|
            payment_hsh[cc_data] = cc_hsh[cc_data]
            cc_hsh.delete(cc_data)
        end
        payment  = PaymentGateway.new(payment_hsh)
        resp_hsh = payment.charge
        cc_hsh.merge!(resp_hsh)
        Sale.new cc_hsh
    end
end


    # required => [ giver_id, provider_id, card_id, number, month_year, first_name, last_name, amount ]
    # optional => unique_id

# == Schema Information
#
# Table name: sales
#
#  id             :integer         not null, primary key
#  gift_id        :integer
#  giver_id       :integer
#  card_id        :integer
#  provider_id    :integer
#  transaction_id :string(255)
#  revenue        :decimal(, )
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  resp_json      :text
#  req_json       :text
#  resp_code      :integer
#  reason_text    :string(255)
#  reason_code    :integer
#
