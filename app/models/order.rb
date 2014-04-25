class Order < ActiveRecord::Base
	include Email

	belongs_to  :provider
	belongs_to  :redeem, autosave: true
	belongs_to  :gift
	belongs_to  :sales
	belongs_to  :cards

	before_validation :add_gift_id,     :if => :no_gift_id
	before_validation :add_redeem_id,   :if => :no_redeem_id
	before_validation :add_provider_id, :if => :no_provider_id

	validates_presence_of 	:gift_id, :redeem_id, :provider_id
	validates_uniqueness_of :gift_id, :redeem_id
    # validate   :is_redeemable

	after_create      :update_gift_status
	after_destroy     :rewind_gift_status

	def self.init_with_pos(pos_params, redeem)
		raise if pos_params.nil?
		order = Order.new(pos_params)
		order.send(:add_gift_info, redeem.gift, redeem)
	end

	def self.init_with_gift(gift, server_code=nil)
		server_code = server_code || ""
		order = Order.new(server_code: server_code)
		order.send(:add_gift_info, gift)
		return order
	end

	def ticket_item_ids
		str_json = super
		JSON.parse str_json
	end

	def ticket_item_ids= ary_of_ids
		super(ary_of_ids.to_json)
	end

	def make_order_num
		number   = self.id
		div      = number / 26
		letter2  = number_to_letter(number % 26)
		div2     = div / 10000
		numbers  = make_numbers(div)
		over     = div2 / 26
		letter1  = number_to_letter(div2 % 26)
		return "#{letter1.to_s}#{letter2.to_s}#{numbers.to_s}"
	end

private

	def add_gift_info(gift, redeem=nil)
		if redeem.nil?
			redeem = Redeem.find_by(gift_id: gift.id)
		end

		if redeem
			self.gift_id     = gift.id
			self.provider_id = gift.provider_id
			self.redeem_code = redeem.redeem_code
			self.redeem 	 = redeem
			redeem.redeem_code = nil
		end
		self
	end

	def update_gift_status
		gift = self.gift
		gift.order_num   = self.make_order_num
		gift.status      = 'redeemed'
		gift.redeemed_at = self.created_at
		gift.server      = self.server_code
		puts "-----------------------------------------------"
		if gift.save
			puts "UPDATE GIFT #{gift.order_num} STATUS #{gift.status}"
		else
			puts "FAILED !!! ORDER gift.SAVE #{gift.order_num} STATUS #{gift.status}"
		end
	end

	def rewind_gift_status
		self.gift.update_attributes({status: 'notified' , redeemed_at: nil, order_num: nil})
		puts "UPDATE GIFT STATUS DELETED ORDER ID=#{self.id}, GiftID = #{self.gift.id} #{self.gift.status}"
	end

	def no_gift_id
		self.gift_id.nil?
	end

	def add_gift_id
		puts "ADD GIFT ID"
		self.gift_id = self.redeem.gift_id if self.redeem
	end

	def no_redeem_id
		self.redeem_id.nil?
	end

	def add_redeem_id
		puts "ADD REDEEM ID"
		self.redeem_id = self.gift.redeem.id if self.gift
	end

	def no_provider_id
		self.provider_id.nil?
	end

	def add_provider_id
		puts "ADD PROVIDER ID"
		self.provider_id = self.gift.provider_id if self.gift
	end

	def make_numbers(div)
		num = "%04d" % (div % 10000)
		"-#{num[3]}#{num[0]}-#{num[2]}#{num[1]}"
	end

	def number_to_letter(num)
		return (num + 10).to_s(36).capitalize
	end

#################  VALIDATIONS

    # def is_redeemable
    # 	status = Gift.find(self.gift_id)
    #     case status
    #     when 'redeemed'
    #     	nil
    #     #     errors.add(:gift, "Error - Redeem code is not valid. The gift has already been redeemed.")
    #     when 'expired'
    #         errors.add(:gift, "Error - Redeem code is not valid. The gift has expired.")
    #     when 'incomplete'
    #     	errors.add(:gift, "Error - Gift has not ben registered with a recipient.")
    #     when 'open'
    #     	nil
    #     when 'notified'
    #     	nil
    #     else
    #     	errors.add(:gift, "Error - Gift is not valid.")
    #     end
    # end
end
# == Schema Information
#
# Table name: orders
#
#  id          :integer         not null, primary key
#  redeem_id   :integer
#  gift_id     :integer
#  redeem_code :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  server_code :string(255)
#  server_id   :integer
#  provider_id :integer
#  employee_id :integer
#

