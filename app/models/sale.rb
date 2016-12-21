class Sale < ActiveRecord::Base
    include MoneyHelper
    validates_presence_of :giver_id, :card_id, :resp_code, :gateway

#   -------------

    # before_save :set_usd_cents   # running this on a background thread

#   -------------

    has_one :gift, as: :payable
    has_one :refunded, class_name: "Gift", as: :refund
    belongs_to :provider
    belongs_to :merchant
    belongs_to :giver, class_name: "User"
    belongs_to :card

#   -------------

    after_commit :notify_developers_for_missing_data

#   -------------

    def self.charge_card cc_hsh, giver=nil
        puts "\n Sale.charge_card #{cc_hsh.inspect}\n"

        # {"amount"=>"27.3", "unique_id"=>"r-David_Leibner+m-590+u-45",
        #    "card_id"=>980193262, "giver_id"=>45, "merchant_id"=>"590",
        #    "cim_profile"=>"123944998", "cim_token"=>"283107841", 'ccy'=>'USD'}

         # {"amount"=>"0.0", "ccy"=>"USD", "unique_id"=>"r-David|m-10|u-7689", "card_id"=>980191948,
         #    "giver_id"=>7689, "merchant_id"=>10, "stripe_id"=>"card_18yDTbHMscfhJNrcYaJvkx6a",
         #  "stripe_user_id"=>"cus_9GkzzcqBi0Z9Q7"}


        cc_hsh.stringify_keys!

        if cc_hsh['amount'].to_f == 0
            self.charge_zero_amount cc_hsh
        elsif cc_hsh['stripe_id'].present?
            self.charge_stripe cc_hsh, giver
        elsif cc_hsh["cim_profile"].present? && cc_hsh["cim_token"].present?
            cc_hsh.delete('ccy')
            self.charge_cim_token cc_hsh
        else
            cc_hsh.delete('ccy')
            cc_hsh = cc_hsh.except("cim_token", "cim_profile")
            self.charge_number_then_tokenize cc_hsh
        end

    end

    def self.charge_zero_amount cc_hsh
        s = Sale.new
        s.request = cc_hsh
        s.response =  {"response_code"=>"1", "response_subcode"=>"1", "response_reason_code"=>"1", "response_reason_text"=>"This transaction has been approved.", "transaction_id"=> cc_hsh['unique_id'], "amount"=>"0.0" }
        s.revenue_cents = 0
        s.revenue = 0
        s.gateway = 'free'
        s.resp_code = 1
        s.reason_text = "This transaction has been approved."
        s.reason_code = 1
        s.merchant_id = cc_hsh["merchant_id"]
        s.giver_id = cc_hsh["giver_id"]
        s.card_id = cc_hsh["card_id"]
        s.transaction_id = cc_hsh['unique_id']
        s.ccy = cc_hsh['ccy']
        s
    end

    def self.charge_stripe cc_hsh, giver=nil
        o = OpsStripe.new cc_hsh
        o.add_customer = giver if giver
        o.purchase

        puts o.inspect

        sale_init_hsh = {"card_id" => cc_hsh["card_id"], "giver_id" => cc_hsh["giver_id"], "merchant_id" => cc_hsh["merchant_id"], 'ccy' => cc_hsh['ccy']}
        resp_hsh = o.gateway_hash_response
        sale_init_hsh.merge!(resp_hsh)
        s  = Sale.new sale_init_hsh
        s.gateway = 'stripe'
        s
    end

#   -------------

    def revenue= amount_str
        rev = amount_str.to_s
        self.revenue_cents = currency_to_cents(rev)
        self.usd_cents = self.revenue_cents if self.ccy == 'USD'
        super rev
    end

    def success?
        self.resp_code == 1
    end

    def response
        JSON.parse self.resp_json
    rescue
        nil
    end

    def response= hsh
        self.resp_json = hsh.to_json
    end

    def request
        JSON.parse self.req_json
    rescue
        nil
    end

    def request= hsh
        self.req_json = hsh.to_json
    end

#   -------------

    def void_refund
        return "Missing Transaction ID - Please refund in #{self.gateway}" if self.transaction_id.nil?
        if self.gateway == 'stripe'
            o = OpsStripe.new
            o.refund(self.transaction_id)
            resp_hsh = o.gateway_hash_response
            s = Sale.new resp_hsh
            s.gateway = 'stripe'
        else
            payment_hsh = {}
            payment_hsh["transaction_id"] = self.transaction_id
            payment_hsh["last_four"] = sale_card_last_four
            payment_hsh["amount"] = self.revenue
            payment  = PaymentGateway.new(payment_hsh)
            resp_hsh = payment.refund
            s = Sale.new resp_hsh
            s.gateway = 'authorize'
        end
        s.giver_id = self.giver_id
        s.card_id = self.card_id
        s.merchant_id = self.merchant_id
        s.gift_id = self.gift_id
        s
    end


#   -------------


    def set_usd_cents
        return true unless self.usd_cents.nil?
        self.usd_cents = self.revenue_cents

        if self.resp_code == 1 && self.gateway == 'stripe' && self.ccy != 'USD'
            o = OpsStripe.new
            bt = o.retrieve(self.transaction_id)
            self.usd_cents = bt.balance_transaction.amount
        end

    rescue => e
        puts "500 Internal - Sale  #{self.id} :usd_cents ERROR fail #{e.inspect} #{self.revenue_cents} #{self.transaction_id} "
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
        s = Sale.new cc_hsh
        s.gateway = 'authorize'
        s
    end

    # def self.charge_trans_token cc_hsh
    #     resp_hsh = OpsFirstData.purchase cc_hsh['trans_token'], cc_hsh["amount"]

    #     sale_init_hsh = { "card_id" => cc_hsh["card_id"], "giver_id" => cc_hsh["giver_id"], "merchant_id" => cc_hsh["merchant_id"] }
    #     sale_init_hsh.merge!(resp_hsh)
    #     Sale.new sale_init_hsh
    # end

    def self.charge_cim_token cc_hsh
        payment_hsh   = {"amount" => cc_hsh["amount"], "cim_token"=> cc_hsh["cim_token"], "cim_profile"=> cc_hsh["cim_profile"],  "unique_id"=> cc_hsh["unique_id"]}
        payment       = PaymentGatewayCim.new(payment_hsh)
        resp_hsh      = payment.charge

        sale_init_hsh = {"card_id" => cc_hsh["card_id"], "giver_id" => cc_hsh["giver_id"], "merchant_id" => cc_hsh["merchant_id"]}
        sale_init_hsh.merge!(resp_hsh)
        s = Sale.new sale_init_hsh
        s.gateway = 'authorize'
        s
    end

#   -------------

    def sale_card_last_four
        if self.card
            self.card.last_four
        else
            req = JSON.parse self.req_json
            req["card_num"][4..7]
        end
    end

    def notify_developers_for_missing_data
        if self.transaction_id.nil? && (self.created_at > 2.minutes.ago)
            OpsTwilio.text_devs msg: "Sale w/o Transaction ID #{self.id}"
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

