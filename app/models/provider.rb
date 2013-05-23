class Provider < ActiveRecord::Base

	attr_accessible :address, :city, :description, :logo, :name,
	:state, :user_id, :staff_id, :zip, :zinger, :phone, :email,
	:twitter, :facebook, :website, :users, :photo, :photo_cache,
	:logo_cache, :box, :box_cache, :portrait, :portrait_cache,
	:account_name, :aba, :routing, :bank_account_name, :bank_address,
	 :bank_city, :bank_state, :bank_zip, :sales_tax

	attr_accessible :crop_x, :crop_y, :crop_w, :crop_h
	attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

	has_many   :users, :through => :employees
	has_many   :employees, dependent: :destroy
	has_many   :relays
	has_many   :menus, dependent: :destroy
	has_many   :orders
	has_one    :menu_string, dependent: :destroy
	has_many   :gifts
	has_many   :sales
	has_and_belongs_to_many   :tags
	belongs_to :brands
	has_many   :servers, class_name: "Employee"

	mount_uploader :photo,    ProviderPhotoUploader
	mount_uploader :logo,     ProviderLogoUploader
	mount_uploader :box,      ProviderBoxUploader
	mount_uploader :portrait, ProviderPortraitUploader

	validates_numericality_of :sales_tax
	validates_length_of :state , :is => 2
	validates_length_of :zip, :within => 5..10
	validates_length_of :aba, :is => 9, :if => :aba_exists?
	validates_length_of :routing, :within => 9..14, :if => :routing_exists?
	validates_presence_of :name, :city, :address, :zip , :state, :phone, :sales_tax
	validates :phone , format: { with: VALID_PHONE_REGEX }, uniqueness: true, :if => :phone_exists?

	before_save :extract_phone_digits
	before_create :create_token      # creates unique  token for provider
	after_create :make_menu_string

	def serialize
		prov_hash  = self.serializable_hash only: [:name, :phone, :sales_tax, :city]
		prov_hash["provider_id"]  = self.id.to_s
		prov_hash["photo"]        = self.get_image("photo")
		prov_hash["full_address"] = self.full_address
		prov_hash["live"]         = self.live
		return prov_hash
	end

	def merchantize
		prov_hash  = self.serializable_hash only: [:name, :phone, :sales_tax, :token, :address, :city, :state, :zip]
		prov_hash["photo"] = self.get_image("photo")
		return prov_hash
	end

	def live
		if self.sd_location_id == nil
			return "0"
		else
			return "1"
		end
	end

	def live_bool
		if self.sd_location_id == nil
			return false
		else
			return true
		end
	end

	def self.where(params={}, *args)
		if params.kind_of?(Hash) && !params.has_key?(:active) && !params.has_key?("active")
			params[:active] = true
			super(params, *args)
		elsif params.kind_of?(String)
			super(params, *args).where(active: true)
		else
			super(params, *args)
		end
	end

	def self.all
		self.where({})
	end

	def get_todays_credits
		self.orders.where("updated_at > ?", (Time.now - 1.day))
	end

	def self.allWithinBounds(bounds)
		puts bounds
		Provider.where(:latitude => (bounds[:botLat]..bounds[:topLat]), :longitude => (bounds[:leftLng]..bounds[:rightLng]))
	end

	def full_address
		"#{self.address},  #{self.city}, #{self.state}"
	end

	def complete_address
		"#{self.address}\n#{self.city_state_zip}"
	end

	def city_state_zip
		"#{self.city}, #{self.state} #{self.zip}"
	end

	def get_photo
		if self.photo.blank?
			MERCHANT_DEFAULT_IMG
		else
			self.photo.url
		end
	end

	def token
		token = super
		if token.nil?    # lazy create & save merchant token
			create_token
			if self.save
				token = super
			else
				puts "Provider lazy token FAIL #{self.id}"
				token = self.errors.messages
			end
		end
		return token
	end

	def sales_tax
		tax = super
		tax.nil? || tax.empty? ? "8" : tax
	end

	def sales_tax=(sales_tax)
		unless sales_tax.nil?
			sales_tax.gsub!('%', '')
			sales_tax.gsub!(' ', '')
		end
		super(sales_tax)
	end

	def get_photo_for_web
		if self.photo.blank?
			MERCHANT_DEFAULT_IMG
		else
			self.photo.url
		end
	end

	def get_image(flag)
		case flag
		when "logo"
			photo = self.logo.url
		when "portrait"
			photo = self.portrait.url
		when "photo"
			photo = self.photo.url
		else
			photo = self.box.url
		end
		if photo.blank?
			photo = MERCHANT_DEFAULT_IMG
		end
		return photo
	end

	def get_servers
		# this means get people who are AT work not just employed
		# for now without location data,
		# its just employees who  are active and retail (deal with customers)
		self.employees.where(active: true)
	end

	def user_clearance(user)
		if user.admin
			return "super"
		else
			emp = self.employees.where(user_id: user.id).pop
			return emp.clearance
		end
	end

	def server_codes
		self.employees.collect {|e| e.server_code}
	end

	def get_server_from_code(code)
		self.employees.select {|e| e.server_code == code}
	end

	def get_server_from_code_to_iphone(code)
		server_in_array = self.employees.select {|e| e.server_code == code}
		server = server_in_array.pop
		server.server_info_to_iphone if server
	end

	def server_to_iphone
		if self.employees.count != 0
			send_fields = [:first_name, :last_name, :server_code]
			self.users.map { |e| e.serializable_hash only: send_fields  }
		else
			"no servers set up yet"
		end
	end

	def users_not_staff
		employees = self.employees
		ids       = employees.map {|e| e.user_id }
		people    = []
		users     = User.all
		users.each do |user|
			if ids.include? user.id
				employee = Employee.where(user_id: user.id, provider_id: self.id).pop
				if employee.active == false
					people << user
				end
			else
				people << user
			end
		end
		return people
	end

	def employees_to_app
		# get all the employees - put there table view info and secure image into an array
		send_fields = [:first_name, :last_name]
		employees_array = self.get_servers.map do |e|
			employee_hash = {}
			employee_hash = e.user.serializable_hash only: [:first_name, :last_name]
			employee_hash["photo"]        = e.user.get_photo
			employee_hash["secure_image"] = e.user.get_secure_image
			employee_hash["employee_id"]  = "#{e.id}"
			employee_hash
		end
		if employees_array.count == 0
			employees_array = ["no employees set up yet"]
		end
		return employees_array
	end

	def employees_to_merchant_tools
		# get all the employees - put there table view info and secure image into an array
		employees_array = self.get_servers.map do |e|
			employee_hash = {}
			employee_hash = e.user.serializable_hash only: [:first_name, :last_name]
			employee_hash["photo"]      = e.user.get_photo
			employee_hash["email"]      = e.user.email
			employee_hash["phone"]      = e.user.phone
			employee_hash["code"]       = e.user.server_code
			employee_hash["clearance"]  = e.clearance
			employee_hash["eid"]        = e.id
			employee_hash
		end

		if employees_array.count == 0
			employees_array = ["no employees set up yet"]
		end
		return employees_array
	end

	def table_photo_hash
				# return the merchant name
				# return the table view photo url
				# call the table view photo at 320px x 50px off cloudinary
		response = {}
		response["provider_name"]   = self.name
		response["photo"]           = self.photo.url
		response["provider_id"]     = self.id.to_s
		response["phone"]           = self.phone.to_s
		response["city"]            = self.city
		response["sales_tax"]       = self.sales_tax
		response["full_address"]    = self.full_address
		return response
	end

private
		def extract_phone_digits
			if self.phone && !self.phone.empty?
				phone_raw   = self.phone
				phone_match = phone_raw.match(VALID_PHONE_REGEX)
				self.phone  = phone_match[1] + phone_match[2] + phone_match[3]
			end
		end

		def phone_exists?
			self.phone != nil && !self.phone.empty?
		end

		def aba_exists?
			self.aba != nil && !self.aba.empty?
		end

		def routing_exists?
			self.routing != nil && !self.routing.empty?
		end

		def create_token
			self.token = SecureRandom.urlsafe_base64
		end

		def make_menu_string
		    Menu_string.create(provider_id: self.id, data: "[]")
		end
end
# == Schema Information
#
# Table name: providers
#
#  id                :integer         not null, primary key
#  name              :string(255)     not null
#  zinger            :string(255)
#  description       :text
#  address           :string(255)
#  address_2         :string(255)
#  city              :string(32)
#  state             :string(2)
#  zip               :string(16)
#  logo              :string(255)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  phone             :string(255)
#  email             :string(255)
#  twitter           :string(255)
#  facebook          :string(255)
#  website           :string(255)
#  photo             :string(255)
#  sales_tax         :string(255)
#  active            :boolean         default(TRUE)
#  account_name      :string(255)
#  aba               :string(255)
#  routing           :string(255)
#  bank_account_name :string(255)
#  bank_address      :string(255)
#  bank_city         :string(255)
#  bank_state        :string(255)
#  bank_zip          :string(255)
#  portrait          :string(255)
#  box               :string(255)
#  latitude          :float
#  longitude         :float
#  foursquare_id     :string(255)
#  rate              :decimal(, )
#

