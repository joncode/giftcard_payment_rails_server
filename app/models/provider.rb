class Provider < ActiveRecord::Base
	include Formatter

	attr_accessible :address, :city, :description, :logo, :name,
	:state, :user_id, :staff_id, :zip, :zinger, :phone, :email,
	:twitter, :facebook, :website, :users, :photo, :photo_cache,
	:logo_cache, :box, :box_cache, :portrait, :portrait_cache,
	:account_name, :aba, :routing, :bank_account_name, :bank_address,
	:bank_city, :bank_state, :bank_zip, :sales_tax, :token, :image, :merchant_id,
	:paused, :live

	attr_accessible :crop_x, :crop_y, :crop_w, :crop_h
	attr_accessor 	:crop_x, :crop_y, :crop_w, :crop_h

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

	validates_presence_of :name, :city, :address, :zip , :state, :token
	validates_length_of :state , 	:is => 2
	validates_length_of :zip, 		:within => 5..10
	validates :phone , format: { with: VALID_PHONE_REGEX }, uniqueness: true, :if => :phone_exists?

	before_save 	:extract_phone_digits
	after_create 	:make_menu_string

	default_scope where(active: true).order("name ASC")

#/---------------------------------------------------------------------------------------------/

	def self.get_all
		unscoped.order("name ASC")
	end

	def serialize
		prov_hash  = self.serializable_hash only: [:name, :phone, :sales_tax, :city, :latitude, :longitude]
		prov_hash["provider_id"]  = self.id
		prov_hash["photo"]        = self.get_image("photo")
		prov_hash["full_address"] = self.full_address
		prov_hash["live"]         = self.live_int
		return prov_hash
	end

	def admt_serialize
		prov_hash  = self.serializable_hash only: [:name, :address, :state, :city, :brand_id, :building_id ]
		prov_hash["provider_id"]  = self.id
		prov_hash["merchant_id"]  = self.merchant_id
		return prov_hash
	end

	def merchantize
		prov_hash  = self.serializable_hash only: [:name, :phone, :sales_tax, :token, :address, :city, :state, :zip, :zinger, :description]
		prov_hash["photo"] = self.get_image("photo")
		return prov_hash
	end

#########   STATUS METHODS

	def live_int
		self.live ? "1" : "0"
	end

	def live_bool
		self.live
	end

	def legacy_status
		stat = if self.active
			if self.sd_location_id == 1
			    "live"
			else
			    "coming_soon"
			end
		else
			"paused"
		end
		status = stat
		save
		puts "provider #{self.id} - Now = #{status} - Old = |#{sd_location_id} | #{self.active}"
	end

	def status
	    if not self.paused
	        if live_bool
	            "live"
	        else
	            "coming_soon"
	        end
	    else
	        "paused"
	    end
	end

	def status= status
		if status 	   == "live"
			self.paused = false
			self.live   = true
		elsif status   == "coming_soon"
			self.paused = false
			self.live   = false
		elsif status   == "pause"
			self.pause  = true
		end
	end

	def get_todays_credits
		self.orders.where("updated_at > ?", (Time.now - 1.day))
	end

	def self.allWithinBounds(bounds)
		puts bounds
		Provider.where(:latitude => (bounds[:botLat]..bounds[:topLat]), :longitude => (bounds[:leftLng]..bounds[:rightLng]))
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

	######   PHOTO GETTERS

	def get_photo_for_web
		get_photo
	end

	def get_photo
		if image.blank?
			if photo.blank?
				MERCHANT_DEFAULT_IMG
			else
				photo.url
			end
		else
			image
		end
	end

	def get_image(flag)
		image_url =
			case flag
			when "logo"
				logo.url
			when "portrait"
				portrait.url
			when "photo"
				get_photo
			else
				box.url
			end
		if image_url.blank?
			image_url = MERCHANT_DEFAULT_IMG
		end
		return image_url
	end

	#################

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
		staff_ids = self.employees.where(active: true).map { |e| e.user_id }
		User.all.delete_if { |user| staff_ids.include? user.id }
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

	def make_menu_string
	    MenuString.create(provider_id: self.id, data: "[]")
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
#  menu_is_live      :boolean         default(FALSE)
#  sd_location_id    :integer
#  brand_id          :integer
#  building_id       :integer
#  token             :string(255)
#  tools             :boolean         default(FALSE)
#  image             :string(255)
#

