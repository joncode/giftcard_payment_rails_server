class Sale < ActiveRecord::Base

    belongs_to :provider
    belongs_to :giver, class_name: "User"
    belongs_to :card

    has_one :gift, as: :payable
    has_one :refunded, class_name: "Gift", as: :refund

    validates_presence_of :giver_id, :card_id, :resp_code

    def success?
        self.resp_code == 1
    end

    def self.charge_card cc_hsh
        if cc_hsh["cim_profile"].present? && cc_hsh["cim_token"].present?
            self.charge_token cc_hsh
        else
            cc_hsh = cc_hsh.except("cim_token", "cim_profile")
            self.charge_number_then_tokenize cc_hsh
        end
    end

    def void_refund giver_id
        payment_hsh = {}
        payment_hsh["trans_id"]  = self.transaction_id
        payment_hsh["last_four"] = sale_card_last_four
        payment_hsh["amount"]    = self.revenue
        payment  = PaymentGateway.new(payment_hsh)
        resp_hsh = payment.refund
        resp_hsh["card_id"]  = self.card_id
        resp_hsh["giver_id"] = giver_id

        Sale.new resp_hsh
    end

private

    def self.charge_number_then_tokenize cc_hsh
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
        card_id = cc_hsh["card_id"]
        unless Rails.env.test?
            Resque.enqueue(CardTokenizerJob, card_id)
        end
        Sale.new cc_hsh
    end

    def self.charge_token cc_hsh
        payment_hsh   = {"amount" => cc_hsh["amount"], "cim_token"=> cc_hsh["cim_token"], "cim_profile"=> cc_hsh["cim_profile"],  "unique_id"=> cc_hsh["unique_id"]}
        payment       = PaymentGatewayCim.new(payment_hsh)
        resp_hsh      = payment.charge

        sale_init_hsh = {"card_id" => cc_hsh["card_id"], "giver_id" => cc_hsh["giver_id"], "provider_id" => cc_hsh["provider_id"]}
        sale_init_hsh.merge!(resp_hsh)
        Sale.new sale_init_hsh
    end

    def sale_card_last_four
        if self.card
            self.card.last_four
        else
            req = JSON.parse self.req_json
            req["card_num"][4..7]
        end
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

