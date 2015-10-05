class Gift < ActiveRecord::Base
    extend  GiftScopes
    include GiftLifecycle
    include Formatter
    include Email
    include GiftSerializers
    include GenericPayableDucktype
    include RedeemHelper
    include GiftMessenger
    include ModelValidationHelper

    TEXT_STATUS_OLD = { "incomplete" => 10, "open" => 20, "notified" => 30, "redeemed" => 40, "regifted" => 50, "expired" => 60, "cancel" => 70 }
    GIVER_STATUS    = { 10 => "incomplete" , 20 => "notified", 30 => "notified", 40 => "complete", 50 => "complete", 60 => "expired", 70 => "cancel" }
    RECEIVER_STATUS = { 10 => "incomplete" , 20 => "open", 30 => "notified",     40 => "redeemed", 50 => "regifted", 60 => "expired", 70 => "cancel" }
    BAR_STATUS      = { 10 => "live" ,       20 => "live",     30 => "live",     40 => "redeemed", 50 => "regifted", 60 => "expired", 70 => "cancel" }

    default_scope -> { where(active: true) } # indexed
    scope :meta_search, ->(str) {
      where("ftmeta @@ plainto_tsquery(:search)", search: str.downcase)
    }

#   -------------

    before_validation { |gift| gift.receiver_email = strip_and_downcase(receiver_email)   if receiver_email.kind_of?(String) }
    before_validation { |gift| gift.receiver_phone = extract_phone_digits(receiver_phone)   if receiver_phone.kind_of?(String) }
    before_validation :prepare_email
    before_validation :build_oauth
    before_validation :format_value
    before_validation :format_cost

#   -------------

    validates_presence_of :giver, :receiver_name, :merchant_id, :value, :shoppingCart, :cat
    validates :receiver_email , format: { with: VALID_EMAIL_REGEX }, allow_blank: :true
    validates :receiver_phone , format: { with: VALID_PHONE_REGEX }, allow_blank: :true
    validates_with GiftReceiverInfoValidator

#   -------------

    before_create :find_receiver
    before_create :add_giver_name,      if: :no_giver_name?
    before_create :add_merchant_name,   if: :no_provider_name?
    before_create :regift,              if: :regift?
    before_create :build_gift_items
    before_create :set_balance
    before_create :set_status_and_pay_stat    # must be last before_create

    after_create :set_affiliate_link
    after_create :set_client_content

    after_save :fire_after_save_queue

#   -------------

    #has_one     :redeem,       dependent: :destroy
    #has_one     :order,        dependent: :destroy
    has_one     :oauth,         validate: true,     dependent: :destroy
    has_one     :sms_contact,   autosave: true
    has_many    :gift_items,    dependent: :destroy
    has_many    :dittos,        as: :notable
    has_many    :redemptions
    has_many    :affiliate_gifts
    has_many    :affiliates,    through: :affiliate_gifts
    has_many    :landing_pages, through: :affiliate_gifts
    has_many    :registers
    belongs_to  :provider
    belongs_to  :merchant
    belongs_to  :giver,         polymorphic: :true
    belongs_to  :receiver,      class_name: User
    belongs_to  :payable,       polymorphic: :true, autosave: :true
    belongs_to  :refund,        polymorphic: :true
    belongs_to :client
    belongs_to :partner, polymorphic: true

#   -------------

    attr_accessor :receiver_oauth

#   -------------

    def value
        if self.status == 'notified' && self.balance.present?
            string_to_cents(number_to_currency((self.balance/100.0), unit: "" , delimiter: ""))
        else
            super
        end
    end

    def set_affiliate_link
        if @link.present?
            Accountant.affiliate_link(self, @link)
        end
    end

    def link= link
        @link = link
        self.origin = link
    end

    def obscured_id
        NUMBER_ID + self.id
    end

    def initialize args={}
        pre_init(args)
        args['shoppingCart'] = stringify_shopping_cart_if_array(args['shoppingCart'])
        super
    end

    def receiver= user_obj
        self.receiver_name = user_obj.name if user_obj
        super
    end

    def giver= giver_obj
        self.giver_name = giver_obj.name if giver_obj
        super
    end

    def provider= provider_obj
        self.provider_name = provider_obj.name if provider_obj
        self.merchant = provider_obj
    end

    def merchant= provider_obj
        self.provider_name = provider_obj.name if provider_obj
        super
    end

    def phone
        self.receiver_phone
    end

    def phone= phone_number
        self.receiver_phone = phone_number
    end

    def grand_total
        pre_round = self.value.to_f + self.service.to_f
        float_to_cents(pre_round.round(2))
    end

    def service
        string_to_cents super
    end

    def service_f
        self.service.to_f.round(2)
    end

    def total
        string_to_cents(self.value)
    end

    def value_in_cents
        (self.value.to_f.round(2) * 100).to_i
    end

    def total= amount
        self.value = amount
    end

    def value_f
        self.value.to_f.round(2)
    end

    def fee
        case self.giver_type
        when "User"
            -(value_f * 0.15).round(2)
        else
            0.0
        end
    end

    def location_fee
        if [300,301,307].include? self.cat
            return merchant.location_fee(self.value_in_cents)
        elsif [100,101,107,150,151,157].include? self.cat
            return (self.cost.to_f * 100).to_i
        else
            return 0
        end
    end

    def redeem_time
        self.redeemed_at || self.created_at
    end

#/-----------------------------------------------Status---------------------------------------/

    def stat_int
        TEXT_STATUS_OLD[self.status]
    end

    def receiver_status
        RECEIVER_STATUS[stat_int]
    end

    def giver_status
        GIVER_STATUS[stat_int]
    end

    def bar_status
        BAR_STATUS[stat_int]
    end

    def set_status_and_pay_stat
        case self.resp_code
        when 1
          # Approved
            if self.pay_stat != 'refund_comp'
                self.pay_stat = "charge_unpaid"
            end
            set_status
        when 2
          # Declined
            self.pay_stat = "payment_error"
            self.status = "cancel"
        when 3
          # Error
            if self.reason_code == 11
                self.pay_stat = "payment_error"
            else
                self.pay_stat = "payment_error"
            end
            self.status = "cancel"
        when 4
          # Held for Review
            self.pay_stat = "payment_error"
            self.status = "cancel"
        else
          # not a listed error code
            self.pay_stat = "payment_error"
            self.status = "cancel"
        end
    end

#/----------------------------------payable ducktype refund -----------------------------/

    def void_refund_cancel
        payment_ducktype = self.payable
        self.refund      = payment_ducktype.void_refund(self.giver_id)

        resp_hsh = {}
        if self.refund.success?
            self.status      = 'cancel'
            self.pay_stat    = "refund_cancel"
            self.redeemed_at = Time.now.utc
            resp_hsh["msg"]  = refund.reason_text
            resp_hsh["status"] = 1
        else
            resp_hsh["msg"] = "#{refund.reason_text} ID = #{self.id}."
            resp_hsh["status"] = 0
        end
        self.save
        resp_hsh
    end

    def void_refund_live
        payment_ducktype = self.payable
        self.refund      = payment_ducktype.void_refund(self.giver_id)
        resp_hsh = {}
        if self.refund.success?
            self.pay_stat   = "refund_comp"
            resp_hsh["msg"] = refund.reason_text
            resp_hsh["status"] = 1
        else
            resp_hsh["msg"] = "#{refund.reason_text} ID = #{self.id}."
            resp_hsh["status"] = 0
        end
        self.save
        resp_hsh
    end


#/-------------------------------------re gift db methods-----------------------------/

	def parent
        self.payable
        #Gift.find(self.regift_id)
	end

	def child
        Gift.where(payable_id: self.id, payable_type: "Gift").first
        #Gift.find_by(regift_id: self.id)
	end

#/-------------------------------------data population methods-----------------------------/

	def remove_receiver
		self.status         = 'incomplete'
		self.receiver_id    = nil
		self.receiver_name  = nil
		self.facebook_id    = nil
		self.receiver_phone = nil
		self.receiver_email = nil
		self.twitter		= nil
	end

	def add_receiver receiver
		if receiver.id
			self.status 	  = 'open'
			self.receiver_id  = receiver.id
		else
		 	self.receiver_id  = nil
		 	self.status 	  = 'incomplete'
		end
		self.receiver_name  = receiver.name
		self.facebook_id    = receiver.facebook_id ? receiver.facebook_id : nil
		self.twitter        = receiver.twitter ? 	 receiver.twitter : nil
		self.receiver_phone = receiver.phone ? 		 receiver.phone : nil
		self.receiver_email = receiver.email
	end

	def add_giver sender
		self.giver   	= sender
		self.giver_name = sender.name
	end

	def add_provider provider
		self.provider_id   = provider.id
		self.provider_name = provider.name
	end

	def add_anonymous_giver giver_id
		anon_user       = User.find_by(phone:  '5555555555')
		self.add_giver anon_user
		self.anon_id    = giver_id
	end

    def receiver_info_as_hsh
        rec_hsh = {}
        rec_hsh["receiver_email"]   = self.receiver_email if self.receiver_email
        rec_hsh["receiver_phone"]   = self.receiver_phone if self.receiver_phone
        rec_hsh["facebook_id"]      = self.facebook_id    if self.facebook_id
        rec_hsh["twitter"]          = self.twitter        if self.twitter
        rec_hsh
    end

    def get_first_regifting_parent
        if self.payable_type == "Gift"
            parent = self.payable
            if parent.payable_type == "Gift"
                parent.get_first_regifting_parent
            else
                parent
            end
        else
            nil
        end
    end

    def stringify_shopping_cart_if_array shoppingCart
        if shoppingCart.kind_of?(Array)
            shoppingCart.to_json
        else
            shoppingCart
        end
    end

    def ary_of_shopping_cart_as_hash
        if self.shoppingCart.kind_of?(String)
            JSON.parse self.shoppingCart
        else
            sc = self.shoppingCart
            self.shoppingCart = self.shoppingCart.to_json
            sc
        end
    end

###############

private

    def set_client_content
        if self.client && self.partner
            self.client.content = self
        end
    end

    def pre_init args={}
        nil
    end

    def post_init args
        nil
    end

    ##########  oauth callback

    def build_oauth
        if self.receiver_oauth.present?
            puts "-----------  Receiver Oauth is present ---------------"
            self.oauth = Oauth.initFromDictionary self.receiver_oauth
            add_network_to_gift
        end
    end

    def add_network_to_gift
        if self.oauth.network_id.present?
            case self.oauth.network
            when "twitter"
                self.twitter     = self.oauth.network_id
            when "facebook"
                self.facebook_id = self.oauth.network_id
            end
        end
    end

	##########  shopping cart methods

	def build_gift_items
        make_gift_items ary_of_shopping_cart_as_hash
	end

	def make_gift_items shoppingCart_array
		self.gift_items = shoppingCart_array.map do |item|
			GiftItem.initFromDictionary(item)
		end
	end

	################  data validation methods

    def set_status
        if self.receiver_id.nil?
            self.status = "incomplete"
        else
            self.status = 'open'
        end
    end

    def prepare_email
        self.receiver_email = nil if self.receiver_id
    end

	def add_giver_name
		if giver = User.find(self.giver_id)
			self.giver_name = giver.username
		end
	end

	def no_giver_name?
		!self.giver_name.present?
	end

    def add_merchant_name
        if merchant = Merchant.unscoped.find(self.merchant_id)
            self.merchant = merchant
            self.provider_name = merchant.name
        end
    end

    def no_provider_name?
        !self.provider_name.present?
    end

    def find_receiver
        if self.receiver_id.nil?
            user = PeopleFinder.find receiver_info_as_hsh
            if user
                self.receiver = user
            end
        end
    end

    def regift
        old_gift = self.payable
        old_gift.update(status: 'regifted', pay_stat: "charge_regifted", redeemed_at: Time.now.utc)
    end

    def regift?
        self.payable.class == Gift
    end

    def format_value
        self.value = string_to_cents(self.value)
    end

    def format_cost
        self.cost = if self.cost.present?
            string_to_cents(self.cost)
        else
            "0"
        end
    end

    def set_balance
        if self.balance.nil?
            self.balance = self.value_in_cents
        end
    end

    def fire_after_save_queue
        puts " --- GIFT AFTER SAVE --- "
        Resque.enqueue(GiftAfterSaveJob, self.id)
    end

end
# == Schema Information
#
# Table name: gifts
#
#  id             :integer         not null, primary key
#  giver_name     :string(255)
#  receiver_name  :string(255)
#  provider_name  :string(255)
#  giver_id       :integer
#  receiver_id    :integer
#  credit_card    :string(100)
#  provider_id    :integer
#  message        :text
#  status         :string(255)     default("unpaid")
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  receiver_phone :string(255)
#  facebook_id    :string(255)
#  receiver_email :string(255)
#  shoppingCart   :text
#  twitter        :string(255)
#  service        :string(255)
#  order_num      :string(255)
#  cat            :integer         default(0)
#  active         :boolean         default(TRUE)
#  pay_stat       :string(255)
#  redeemed_at    :datetime
#  server         :string(255)
#  payable_id     :integer
#  payable_type   :string(255)
#  giver_type     :string(255)
#  value          :string(255)
#  expires_at     :datetime
#  refund_id      :integer
#  refund_type    :string(255)
#  cost           :string(255)
#  detail         :text
#  ftmeta         :tsvector
#  notified_at    :datetime
#  new_token_at   :datetime
#  token          :integer
#  balance        :integer
#  origin         :string(255)
#

