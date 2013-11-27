class Provider < ActiveRecord::Base
	include Formatter

	attr_accessor 	:menu


	has_one    :menu_string, dependent: :destroy
	has_many   :gifts
	has_many   :sales
	has_many   :orders
	belongs_to :brands
	belongs_to :merchant

	validates_presence_of 	:name, :city, :address, :zip , :state, :token
	validates_length_of 	:state , 	:is => 2
	validates_length_of 	:zip, 		:within => 5..10
	validates 				:phone , format: { with: VALID_PHONE_REGEX }, :if => :phone_exists?
	validates_uniqueness_of :token


	before_save 	:extract_phone_digits
	after_create 	:make_menu_string

	default_scope -> { where(active: true).where(paused: false).order("name ASC") }  # indexed w/ city

    def biz_user
        BizUser.find(self.id)
    end
#/---------------------------------------------------------------------------------------------/

	def self.get_all
		unscoped.order("name ASC")
	end

	def serialize
		prov_hash  = self.serializable_hash only: [:name, :phone, :city, :latitude, :longitude]
		prov_hash["provider_id"]  = self.id
		prov_hash["photo"]        = self.get_photo
		prov_hash["full_address"] = self.full_address
		prov_hash["live"]         = self.live_int
		return prov_hash
	end

	alias :to_hash :serialize

	def admt_serialize
		prov_hash  = self.serializable_hash only: [:name, :address, :state, :city, :brand_id, :building_id ]
		prov_hash["provider_id"]  = self.id
		prov_hash["merchant_id"]  = self.merchant_id
		prov_hash["mode"]         = self.mode
		return prov_hash
	end

	def merchantize
		prov_hash  = self.serializable_hash only: [:name, :phone, :sales_tax, :token, :address, :city, :state, :zip, :zinger, :description]
		prov_hash["photo"] = self.get_photo
		return prov_hash
	end

	def web_serialize
		prov_hash  = self.serializable_hash only: [:name, :phone, :city, :latitude, :longitude]
		prov_hash["provider_id"]  = self.id
		prov_hash["photo"]        = self.get_photo
		prov_hash["full_address"] = self.full_address
		prov_hash
	end

#########   STATUS METHODS

	def live_int
		self.live ? "1" : "0"
	end

	def mode
	    if self.paused
	        return "paused"
	    else
	    	if self.live
	    	    return "live"
	    	else
	    	    return "coming_soon"
	    	end
	    end
	end

	def mode= mode_str
		case mode_str.downcase
		when "live"
			self.paused = false
			self.live   = true
		when "coming_soon"
			self.paused = false
			self.live   = false
		when "paused"
			self.paused = true
		else
			# cron job to fix the broken mode_str
			puts "#{self.name} #{self.id} was sent mode_str #{mode_str} - update mode broken"
		end
	end

	def deactivate
		self.paused = true
		self.live 	= false
		self.active = false
		if self.save
			true
		else
			false
		end
	end

##################

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

	def get_photo
		return MERCHANT_DEFAULT_IMG if image.blank?
		image
	end

private

	def make_menu_string
	    MenuString.create(provider_id: self.id, data: "[]", menu: self.menu)
	end

	def update_city_provider
		city = self.city
    	new_providers_array = Provider.where(city: city).serialize_objs.to_json
    	if old_city_provider = CityProvider.find_by(city: city)
    		old_city_provider.update_attribute(:providers_array, new_providers_array)
    	else
    		CityProvider.create(city:city, providers_array: new_providers_array)
    	end
    end

end
# == Schema Information
#
# Table name: providers
#
#  id             :integer         not null, primary key
#  name           :string(255)     not null
#  zinger         :string(255)
#  description    :text
#  address        :string(255)
#  address_2      :string(255)
#  city           :string(32)
#  state          :string(2)
#  zip            :string(16)
#  logo           :string(255)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  phone          :string(255)
#  email          :string(255)
#  twitter        :string(255)
#  facebook       :string(255)
#  website        :string(255)
#  photo          :string(255)
#  sales_tax      :string(255)
#  active         :boolean         default(TRUE)
#  portrait       :string(255)
#  box            :string(255)
#  latitude       :float
#  longitude      :float
#  foursquare_id  :string(255)
#  rate           :decimal(, )
#  menu_is_live   :boolean         default(FALSE)
#  sd_location_id :integer
#  brand_id       :integer
#  building_id    :integer
#  token          :string(255)
#  tools          :boolean         default(FALSE)
#  image          :string(255)
#  merchant_id    :integer
#  live           :boolean         default(FALSE)
#  paused         :boolean         default(TRUE)
#

