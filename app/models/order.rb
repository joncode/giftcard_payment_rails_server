class Order < ActiveRecord::Base
	attr_accessible :gift_id, :redeem_code, :redeem_id, :server_code, :server_id, :provider_id, :employee_id

	belongs_to  :provider
	belongs_to  :redeem
	belongs_to  :gift
	belongs_to  :employee
	belongs_to  :sales
	belongs_to  :cards
	belongs_to  :server, class_name: "User"    #  be class_name "Employee"

	validates :gift_id   , presence: true, uniqueness: true
	validates :redeem_id , presence: true, uniqueness: true
	validates :provider_id , presence: true

	before_validation :add_gift_id,     :if => :no_gift_id
	before_validation :add_redeem_id,   :if => :no_redeem_id
	before_validation :add_provider_id, :if => :no_provider_id
	# before_validation :authenticate_via_code
	after_create      :update_gift_status
	after_create      :notify_giver_order_complete
	after_destroy     :rewind_gift_status

	def self.init_with_gift(gift, server_code=nil)
		order = Order.new
		if redeem = gift.redeem
			order.gift_id     = gift.id
			order.provider_id = gift.provider_id
			order.redeem_id   = redeem.id
			order.redeem_code = redeem.redeem_code
			order.server_code = server_code.to_s
		else
			return order
		end
		return order
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

	def make_numbers(div)
		num = "%04d" % (div % 10000)
		"-#{num[3]}#{num[0]}-#{num[2]}#{num[1]}"
	end

	def number_to_letter(num)
		return (num + 10).to_s(36).capitalize
	end

	def notify_giver_order_complete
		puts "emailing the gift giver for #{self.id}"
		# notify the giver via email
		gift = self.gift
		Resque.enqueue(EmailJob, 'notify_giver_order_complete', gift.giver_id , {:gift_id => gift.id})
	end

	def add_server
		server_ary      = self.provider.get_server_from_code(self.server_code)
		server_obj      = server_ary.pop
		self.server_id  = server_obj.user.id
		puts "found server #{server_obj.name} #{server_obj.id}"
	end

	def update_gift_status
		gift = self.gift
		gift.order_num = self.make_order_num
		gift.status    = 'redeemed'
		if gift.save
			puts "UPDATE GIFT #{gift.order_num} STATUS #{gift.status}"
		else
			puts "FAILED !!! ORDER gift.SAVE #{gift.order_num} STATUS #{gift.status}"
		end
	end

	def rewind_gift_status
		self.gift.update_attribute(:status, 'notified')
		puts "UPDATE GIFT STATUS DELETED ORDER ID=#{self.id}, GiftID = #{self.gift.id} #{self.gift.status}"
	end

	# def authenticate_via_code
	#   puts "AUTHENTICATE VIA CODE"
	#   if self.gift.nil? || self.redeem.nil?
	#     errors.add(:authenticate, "missing gift or redeem")
	#     return false
	#   end
	#   if self.redeem_code
	#               # authentication code for redeem_code
	#     redeem_obj = self.redeem
	#               # set flag for approved/denied - true/false
	#     if self.redeem_code == redeem_obj.redeem_code
	#       flag = true
	#     else
	#       flag = false
	#       puts "CUSTOMER REDEEM CODE INCORRECT"
	#       errors.add(:redeem_code, "Incorrect Redeem Code")
	#     end
	#   elsif self.server_code
	#               # authenticate for server_code
	#     codes = self.provider.server_codes
	#               # set flag for approval/denied - true/false
	#     if codes.include? self.server_code
	#       flag = true
	#       add_server
	#     else
	#       flag = false
	#       puts "MERCHANT REDEEM CODE INCORRECT"
	#       errors.add(:merchant_redeem_code, "Incorrect Merchant Redeem Code")
	#     end
	#   else
	#               # no code provided - set flag to denied - false
	#     errors.add(:redeem_code, "cant be blank")
	#     flag = false
	#   end
	#   return flag
	# end

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

	def get_server_id
		if !self.server_id
			puts "SET SERVER ID"
			self.server_id = self.employee.user.id
		end
	end

	# def get_employee_id
	#   if !self.employee_id
	#     puts "SET EMPLOYEE ID"
	#     e = Employee.where(provider_id: self.gift.provider.id, user_id:  self.server_id)
	#     if e.kind_of? ActiveRecord::Relation
	#       if e.size > 0
	#         employee = e.shift
	#         self.employee_id = employee.id
	#       else
	#         self.employee_id = nil
	#       end
	#     else
	#       self.employee_id = e.id
	#     end
	#   end
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

