class Gift < ActiveRecord::Base
	extend  GiftScopes
	include Formatter
	include Email
	include GiftSerializers

    TEXT_STATUS_OLD = { "incomplete" => 10, "open" => 20, "notified" => 30, "redeemed" => 40, "regifted" => 50, "expired" => 60, "cancel" => 70 }
    GIVER_STATUS    = { 10 => "incomplete" , 20 => "notified", 30 => "notified", 40 => "complete", 50 => "complete", 60 => "expired", 70 => "cancel" }
    RECEIVER_STATUS = { 10 => "incomplete" , 20 => "notified", 30 => "open",     40 => "redeemed", 50 => "regifted", 60 => "expired", 70 => "cancel" }
    BAR_STATUS      = { 10 => "live" ,       20 => "live",     30 => "live",     40 => "redeemed", 50 => "regifted", 60 => "expired", 70 => "cancel" }

	has_one     :redeem, 		dependent: :destroy
	has_one     :order, 		dependent: :destroy

	has_many    :gift_items, 	dependent: :destroy
    belongs_to  :provider
    belongs_to  :giver,    polymorphic: :true
    belongs_to  :receiver, class_name: User
    belongs_to  :payable,  polymorphic: :true, autosave: :true
    belongs_to  :refund,   polymorphic: :true

    before_validation :prepare_email

	validates_presence_of :giver, :receiver_name, :provider_id, :value, :shoppingCart
    validates :receiver_email , format: { with: VALID_EMAIL_REGEX }, allow_blank: :true

    before_save { |gift| gift.receiver_email = receiver_email.downcase if receiver_email }
	before_save   :extract_phone_digits
    before_create :find_receiver
	before_create :add_giver_name,  	:if => :no_giver_name?
    before_create :add_provider_name,   :if => :no_provider_name?
    before_create :regift,              :if => :regift?
	before_create :build_gift_items
	before_create :set_statuses

	default_scope -> { where(active: true) } # indexed

#/---------------------------------------------------------------------------------------------/

    def sale
        Sale.find_by(gift_id: self.id)
    end

    def initialize args={}
        pre_init(args)
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

    def total
        if self.respond_to?(:value)
            amount = self.value || super
            string_to_cents amount
        else
            string_to_cents super
        end
    end

    def total= amount
        self.value = amount
    end

    def unique_cc_id
        "#{self.receiver_name}_#{self.provider_id}".gsub(' ','_')
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

	def set_statuses
		case self.payable_type
		when "Sale"
			set_payment_status
		when "Debt"
            set_status
            self.pay_stat = "charge_unpaid"
		when "Gift"
            set_status
		else
			set_status
		end
	end

	def set_status
		if self.receiver_id.nil?
			self.status = "incomplete"
		else
			self.status = 'open'
		end
	end

	def set_payment_status
		case self.payable.resp_code
		when 1
		  # Approved
			self.pay_stat = "charge_unpaid"
            set_status
		when 2
		  # Declined
			self.pay_stat = "payment_error"
            self.status = "cancel"
		when 3
		  # Error
			if self.payable.reason_code == 11
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

    def promo?
        self.giver_type == "BizUser" && self.payable_type == "Debt"
    end
#/----------------------------------payable ducktype refund -----------------------------/

    def void_refund_cancel
        payment_ducktype = self.payable
        self.refund      = payment_ducktype.void_refund(self.giver_id)

        resp_hsh = {}
        if self.refund.success?
            self.status     = 'cancel'
            self.pay_stat   = "refund_cancel"
            resp_hsh["msg"] = refund.reason_text
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
        #self.payable
        Gift.find(self.regift_id)
	end

	def child
        #Gift.find_by(payable_id: self.id)
        Gift.find_by(regift_id: self.id)
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
		self.receiver_email = receiver.email ? 		 receiver.email : nil
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

###############

private

    def pre_init args={}
        nil
    end

    def post_init args
        nil
    end

	##########  shopping cart methods

	def build_gift_items
        make_gift_items ary_of_shopping_cart_as_hash
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

	def make_gift_items shoppingCart_array
		self.gift_items = shoppingCart_array.map do |item|
			GiftItem.initFromDictionary(item)
		end
	end

	################  data validation methods

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

    def add_provider_name
        if provider = Provider.find(self.provider_id)
            self.provider = provider
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
        old_gift.update(status: 'regifted', pay_stat: "charge_regifted")
    end

    def regift?
        self.payable.class == Gift
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
#  total          :string(20)
#  credit_card    :string(100)
#  provider_id    :integer
#  message        :text
#  status         :string(255)     default("unpaid")
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  receiver_phone :string(255)
#  tax            :string(255)
#  tip            :string(255)
#  regift_id      :integer
#  foursquare_id  :string(255)
#  facebook_id    :string(255)
#  anon_id        :integer
#  sale_id        :integer
#  receiver_email :string(255)
#  shoppingCart   :text
#  twitter        :string(255)
#  service        :string(255)
#  order_num      :string(255)
#  cat            :integer         default(0)
#  active         :boolean         default(TRUE)
#  pay_stat       :string(255)
#  pay_type       :string(255)
#  pay_id         :integer
#  redeemed_at    :datetime
#  server         :string(255)
#  payable_id     :integer
#  payable_type   :string(255)
#  giver_type     :string(255)
#  value          :string(255)
#  expires_at     :datetime
#  refund_id      :integer
#  refund_type    :string(255)
#

