class Gift < ActiveRecord::Base
    extend  GiftScopes
    include GiftLifecycle
    include Formatter
    include MoneyHelper
    include Email
    include GiftSerializers
    include GenericPayableDucktype
    include RedeemHelper
    include GiftMessenger
    include GiftScheduler
    include ModelValidationHelper
    include ShoppingCartHelper

    default_scope -> { where(active: true) } # indexed

    scope :meta_search, ->(str) {
        where("ftmeta @@ plainto_tsquery(:search)", search: str.downcase)
    }

#   -------------

    auto_strip_attributes :receiver_email, :receiver_name, :server

#   -------------

    before_validation { |gift| gift.receiver_email = strip_and_downcase(receiver_email)  if receiver_email.kind_of?(String) }
    before_validation { |gift| gift.receiver_phone = extract_phone_digits(receiver_phone)  if receiver_phone.kind_of?(String) }
    before_validation :build_oauth
    before_validation :format_value
    before_validation :format_cost
    before_validation :set_expires_at
    before_validation :set_scheduled_at
    before_validation :set_unique_hex_id, on: :create

#   -------------

    validates_presence_of :giver, :receiver_name, :merchant_id, :value, :shoppingCart, :cat
    # validates_uniqueness_of :hex_id
    validates :receiver_email , format: { with: VALID_EMAIL_REGEX }, allow_blank: :true
    validates :receiver_phone , format: { with: VALID_PHONE_REGEX }, allow_blank: :true
    validates_with GiftReceiverInfoValidator

#   -------------

    before_create :find_receiver
    before_create :add_giver_name
    before_create :add_merchant_name
    before_create :reject_double_click
    before_create :build_gift_items
    before_create :regift
    before_create :set_balance
    before_create :set_pay_stat    # must be last before_create
    before_create :set_status    # must be last before_create

    before_save   :set_notified_at
    before_save   :set_redeemed_at

    after_create :set_client_content

    after_commit :fire_after_save_queue, on: :create
    after_commit :fire_gift_create_event, on: :create
    after_commit :developer_notify, on: :create

#   -------------

    has_many    :affiliate_gifts
    has_many    :affiliates,    through: :affiliate_gifts
    has_many    :dittos,        as: :notable
    has_many    :gift_items,    dependent: :destroy, autosave: true
    has_many    :landing_pages, through: :affiliate_gifts
    has_one     :oauth,         validate: true,     dependent: :destroy
    has_one     :proto_join
    has_many    :redemptions, -> { get_live_scope }, autosave: true

    def complete_redemptions
        redemptions.where(status: 'done')
    end

    def pending_redemptions
        redemptions.where(status: 'pending')
    end

    has_many    :registers
    has_one     :sms_contact,   autosave: true

    belongs_to :client
    belongs_to :giver,         polymorphic: :true
    belongs_to :merchant
    belongs_to :partner, polymorphic: true
    belongs_to :payable,       polymorphic: :true, autosave: true
    belongs_to :receiver,      class_name: User
    belongs_to :refund,        polymorphic: :true, autosave: true


#   -------------


    attr_accessor :receiver_oauth, :card

    def initialize args={}
        pre_init(args)
        super
    end

    def self.index
        []
    end

    def stoplight meta=nil
        if meta && meta == :help
            return { meta: [ :redemption, :payment, :notified],
                modes: [:stop, :support, :live]
            }
        end
        if !active
            :stop
        elsif self.pay_stat == 'payment_error' || self.status == 'cancel'
            :support
        else
            :live
        end
    end

#   -------------

    def invite_link
        # "#{PUBLIC_URL}/signup/acceptgift?id=#{self.obscured_id}"
        "#{PUBLIC_URL}/hi/#{self.hex_id}"
    end

    def paper_id
        @paper_id ||= set_paper_id
    end

    def set_paper_id
        return '' if self.hex_id.nil?
        hx = self.hex_id.to_s.gsub('_', '-').upcase
        hx[0..6].to_s + '-' + hx[7..10].to_s
    end

    def obscured_id
        NUMBER_ID + self.id
    end

    def self.find_with_obscured_id obscured_id
        find(obscured_id.to_i - NUMBER_ID)
    end

#   -------------


    def display_photo
        self.merchant.get_photo
    end

    def item_photo
        item_with_photo = self.cart_ary.find { |i| i['photo'].present? }
        return item_with_photo['photo'] if item_with_photo.kind_of?(Hash)
        return nil
    end

#   -------------

    def link= link
        @link = link
        self.origin = link
    end


#   -------------

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

    def merchant_name
        self.provider_name
    end

    def phone
        self.receiver_phone
    end

    def phone= phone_number
        self.receiver_phone = phone_number
    end


#   -------------


    def service
        super
    end

    def service_s
        display_money cents: service_cents, ccy: self.ccy
    end

    def service_f
        string_to_float self.service
    end

    def service_cents
        currency_to_cents self.service || '0'
    end

    def purchase_cents
        self.original_value.to_i + self.service_cents.to_i
    end

    def purchase_total
        display_money cents: purchase_cents, ccy: self.ccy
    end

    def original_value
        return @original_value if @original_value.present?
        if self.payable_type == "Gift"
            @original_value = self.parent.balance
        else
            @original_value = currency_to_cents(calculate_value(self.shoppingCart).to_s)
        end
    end

    def total
        display_money cents: self.value_cents, ccy: self.ccy
    end

    def total= amount
        self.value = amount
    end

    def value
        if self.status == 'notified' && self.balance.present?
            display_money cents: balance
        else
            super
        end
    end

    def value_s
        display_money cents: value_cents, ccy: self.ccy
    end

    def value_cents
        currency_to_cents(self.value)
    end
    alias_method :value_in_cents, :value_cents

    def value_f
        string_to_float self.value
    end

    def cost_cents
        currency_to_cents(self.cost)
    end

    def fee
        case self.giver_type
        when "User"
            -(self.value_f * (1 - self.merchant.location_fee.to_f)).round(2)
        else
            0.0
        end
    end

    def converted_ccy
        if self.ccy != 'USD' && self.payable_type == 'Sale' && (self.payable.usd_cents != self.payable.revenue_cents)
            'USD'
        else
            self.ccy
        end
    end

    def converted_value_cents
        amt = original_value

        if self.ccy != 'USD' && self.payable_type == 'Sale'
            sale = self.payable
            if sale.usd_cents.nil?
                sale.set_usd_cents
                sale.save
            end
            amt = original_value * sale.usd_cents / sale.revenue_cents
        end
        amt
    end

    def location_fee
        if self.cat >= 300
            return merchant.location_fee(converted_value_cents)
        elsif self.cat < 200
            return cost_cents
        else
            return 0
        end
    end

    def override_fee override_obj=nil
        if self.cat >= 300
            return merchant.override_fee(converted_value_cents)
        elsif self.cat < 200
            return 0
        else
            return 0
        end
    end

    def redeem_time
        self.redeemed_at || self.created_at
    end


#/-----------------------------------------------Status---------------------------------------/


    def set_pay_stat
        case self.resp_code
        when 1
          # Approved
            if self.pay_stat != 'refund_comp'
                self.pay_stat = "charge_unpaid"
            end
        when 2
          # Declined
            self.pay_stat = "payment_error"
        when 3
          # Error
            self.pay_stat = "payment_error"
        when 4
          # Held for Review
            self.pay_stat = "payment_error"
        else
          # not a listed error code
            self.pay_stat = "payment_error"
        end
    end

    def set_status
        if self.pay_stat == "payment_error"
            self.status = "cancel"
        else
            if self.scheduled_at.present? && (self.scheduled_at.to_date >= DateTime.now.utc.to_date)
                # scheduler runs at 14:30 UTC
                if self.scheduled_at.to_date > DateTime.now.utc.to_date
                    self.status = "schedule"
                else # self.scheduled_at.to_date == DateTime.now.utc.to_date
                    if DateTime.now.utc.hour > 14
                        # if its after 14 UTC and scheduled_at is same day as today .. deliver now
                        if self.receiver_id.nil?
                            self.status = "incomplete"
                        else
                            self.status = 'open'
                        end
                    else
                        # if its before 14 UTC and scheduled at is same day as today .. schedule
                        self.status = "schedule"
                    end
                end
            else
                if self.receiver_id.nil?
                    self.status = "incomplete"
                else
                    self.status = 'open'
                end
            end
        end
    end

#/----------------------------------payable ducktype refund -----------------------------/

    def void_refund cancel=true, partial_amt=nil
        if !self.payable.respond_to?(:void_refund)
            return { 'status' => 0 , 'msg' => "You cannot refund a gift made with a #{self.payable_type}"}
        end

        refund = self.payable.void_refund(partial_amt)
        if refund.kind_of?(String)
            return { 'status' => 0, 'msg' => refund }
        end
        refund.gift_id = self.id
        resp_hsh = {}
        if refund.success?
            self.refund = refund
            self.pay_stat = "refund_comp"
            if cancel
                self.status      = 'cancel'
                self.pay_stat    = "refund_cancel"
            end
            if save
                Resque.enqueue(GiftRefundedEvent, self.id)
                return { 'status' => 1, 'msg' => refund.reason_text }
            else
                return { 'status' => 0 , 'msg' => "Gift failed to save refund #{self.errors.full_messages}"}
            end
        else
            if refund.save
                return { 'status' => 0 , 'msg' => "Refund Failed #{refund.reason_text} REFUND ID = #{refund.id}."}
            else
                return { 'status' => 0 ,
                    'msg' => "Refund Failed #{refund.reason_text} - #{refund.errors.full_messages} \
                            REFUND_TRANSACTION = #{refund.transaction_id}."
                }
            end
        end
    end

    def void_refund_cancel partial_amt=nil
        void_refund(true, partial_amt)
    end

    def void_refund_live partial_amt=nil
        void_refund(false, partial_amt)
    end


#/-------------------------------------re gift db methods-----------------------------/


    def regift
        if regift?
            self.payable.update(status: 'regifted', pay_stat: "charge_regifted")
        end
    end

    def regift?
        self.payable.class == Gift
    end

	def parent
        if self.payable_type == 'Gift'
            g = self.payable
            if g.nil?
                Gift.unscoped.where(id: self.payable_id).first
            else
                g
            end
        else
            nil
        end
	end

	def child
        Gift.where(payable_id: self.id, payable_type: "Gift").first
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


#/-------------------------------------data population methods-----------------------------/

    def delivery_method
        if !self.receiver_phone.blank?
            'ph'
        elsif !self.receiver_email.blank?
            'em'
        elsif !self.facebook_id.blank?
            'fb'
        elsif !self.twitter.blank?
            'tw'
        else
            'em'
        end
    end

    def find_receiver
        if self.receiver_id.nil?
            found_user = PeopleFinder.find receiver_info_as_hsh
            if found_user
                self.receiver = found_user
            end
        end
    end

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
		self.twitter        = receiver.twitter ? receiver.twitter : nil
		self.receiver_phone = receiver.phone ? receiver.phone : nil
		self.receiver_email = receiver.email
	end

	def add_giver sender
		self.giver   	= sender
		self.giver_name = sender.name
	end

    def receiver_info_as_hsh
        rec_hsh = {}
        rec_hsh["receiver_email"]   = self.receiver_email if self.receiver_email
        rec_hsh["receiver_phone"]   = self.receiver_phone if self.receiver_phone
        rec_hsh["facebook_id"]      = self.facebook_id    if self.facebook_id
        rec_hsh["twitter"]          = self.twitter        if self.twitter
        rec_hsh
    end


##########  shopping cart methods


    def ary_of_shopping_cart_as_hash
        if self.shoppingCart.kind_of?(String)
            JSON.parse self.shoppingCart
        else
            sc = self.shoppingCart
            self.shoppingCart = self.shoppingCart.to_json
            sc
        end
    end

    def build_gift_items
        # 1. format data into an array
        scart = self.shoppingCart
        if scart.kind_of?(String)
            begin
                ary = JSON.parse(scart)
            rescue
                return
            end
        elsif scart.kind_of?(Array)
            ary = scart
        else
            return
        end
        ary.each { |hsh| hsh.stringify_keys! }

        # 2. get Menu Items
        mhsh = {}
        mids = ary.map{ |h| h['item_id'] }
        MenuItem.where(id: mids).each { |item| mhsh[item.id] = item }

        # 3. create a consistent shopping cart &  make the giftItems
        gift_item_ary = []
        new_cart = []
        ary.each do |item_hsh|
            item_id = item_hsh['item_id'].to_i
            quantity = item_hsh['quantity'].to_i
            mitem = mhsh[item_id]
            if item_hsh['price'].to_f > mitem.price.to_f
                    # price is now lower than customer thinks it will be
                    # ignore
                new_hsh = mitem.serialize_with_quantity(quantity)
            elsif item_hsh['price'].to_f == mitem.price.to_f
                    # all good
                new_hsh = mitem.serialize_with_quantity(quantity)
            elsif item_hsh['price'].to_f < mitem.price.to_f
                    # new price is greater than customer price
                OpsTwilio.text_devs msg: "#{self.id} Menu Item Price is wrong on gift - menu item #{mitem.id} #{mitem.price} at Q #{quantity} - item price = #{item_hsh['price']}"
                hsh = mitem.serialize_with_quantity(quantity)
                hsh['price'] = item_hsh['price']
                new_hsh = hsh
            end
            new_cart << new_hsh
            new_gift_item = GiftItem.initFromDictionary(new_hsh)
            gift_item_ary << new_gift_item
        end

        # 4. stringify - pre-compile shoppingCart and save on attibute
        self.shoppingCart = new_cart.to_json
    end


###############


    def set_client_content
        if self.client && self.partner
            self.client.content = self
        end
    end

    def fire_after_save_queue(sent_client_id=nil)
        if sent_client_id.respond_to?(:id)
            sent_client_id = sent_client_id.id
        end
        puts " REDISWRAP --- GIFT AFTER SAVE --- #{self.id} - #{sent_client_id}"
        Resque.enqueue(GiftAfterSaveJob, self.id, sent_client_id)
    end

    def clear_caches
        RedisWrap.clear_all_user_gifts(self.giver_id) if self.giver_type == 'User'
        RedisWrap.clear_all_user_gifts(self.receiver_id)
    end

    def fire_gift_create_event
        Resque.enqueue(GiftCreatedEvent, self.id)
    end

    def set_unique_hex_id
        self.hex_id = UniqueIdMaker.eight_digit_hex(self.class, :hex_id, 'gf_')
    end


private


    def pre_init args={}
        nil
    end

    def post_init args
        nil
    end

##########  oauth callback

    def build_oauth
        if self.receiver_oauth.present?
            giver_oauth_obj = self.giver.current_oauth
            if giver_oauth_obj.kind_of?(Oauth)
                self.receiver_oauth['token'] = giver_oauth_obj.token
                self.receiver_oauth['photo'] = self.display_photo
            end
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


################  data validation methods



	def add_giver_name
        if self.giver_name.blank?
    		g = self.giver
            if g.respond_to?(:username)
                self.giver_name = giver.username
            elsif g.respond_to?(:fullname)
                self.giver_name = giver.fullname
            elsif g.respond_to?(:name)
                self.giver_name = giver.name
            elsif g.respond_to?(:venue_name)
    			self.giver_name = giver.venue_name
            else
                self.giver_name = "ItsOnMe Group"
            end
        end
	end

    def add_merchant_name
        if self.merchant.multi_redeemable?
            if p = self.merchant.client.partner
                self.provider_name = p.name
            end
        end
        if self.provider_name.blank?
            if m = Merchant.unscoped.find(self.merchant_id)
                self.merchant = m
                self.provider_name = m.name
            end
        end
    end

    def format_value
        self.value = string_to_money(self.value)
    end

    def format_cost
        self.cost = if self.cost.present?
            string_to_money(self.cost)
        else
            "0"
        end
    end

    def set_balance
        if self.balance.nil?
            self.balance = self.value_cents
        end
    end

    def set_scheduled_at
            # have to set expires_at to 12 p, (noon) day of delivery
            # schedule cron runs at UTC 14:30
        if self.scheduled_at.respond_to?(:midday)
            self.scheduled_at = self.scheduled_at.midday
        end
    end

    def set_notified_at
        if self.status == 'notified' && self.notified_at.nil?
            self.notified_at = Time.now.utc
        end
    end

    def set_redeemed_at
        if ['cancel', 'expired', 'regifted', 'redeemed'].include?(self.status) && self.redeemed_at.nil?
            self.redeemed_at = Time.now.utc
        end
    end

    def set_expires_at
            # have to set expires_at to 12 p, (noon) day of expiration ... that is so it will display correct on android (which applys timezone)
            # expiration cron pulls the hours off and just uses the date
        if self.expires_at.respond_to?(:midday)
            self.expires_at = self.expires_at.midday
        end
    end

    def reject_double_click
        return true if self.cat < 300
        x = { merchant_id: self.merchant_id, value: self.value, receiver_name: self.receiver_name, cat: 300 }
        puts x.inspect
        # if resp is false , save is stopped , therefore exists must be true
        resp = !Gift.where(x).where('created_at > ?', 1.minute.ago).where.not(status: 'cancel').exists?
        puts "HERE IS DOUBLE CLICK RESP #{resp}"
        unless resp
            errors.add(:duplicate_gift_submitted, "- Our system detected a second identical gift attempt.  Please wait 1 minute if this is in error")
        end
        return resp
    end

    def developer_notify
        if self.cost.present? && self.cost.length > 6
            # notify_developers
            puts "500 INTERNAL - COST IS WRONG ON GIFT ! "
            OpsTwilio.text_devs msg: "Cost is wrong on gift #{self.id}"
        end
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

