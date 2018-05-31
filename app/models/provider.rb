# class Provider < ActiveRecord::Base
# 	self.table_name = 'merchants'

# 	include Formatter
# 	include ShortenPhotoUrlHelper
# 	include MerchantSerializers

# 	default_scope -> { where(active: true).where(paused: false).order("name ASC") }  # indexed w/ city

# #	-------------

# 	validates_presence_of 	:name, :city_name, :address, :zip, :city_id, :token
# 	validates_length_of 	:state , 	:is => 2
# 	validates 				:zip, 	zip_code: true
# 	validates 				:phone , format: { with: VALID_PHONE_REGEX }, :if => :phone_exists?
# 	validates_uniqueness_of :token

# #	-------------

#     before_save     :add_region_name
# 	before_save 	:extract_phone_digits
# 	after_create 	:make_menu_string
#     after_save 		:clear_www_cache

# #	-------------

# 	has_one    :menu_string, dependent: :destroy
# 	has_many   :gifts
# 	has_many   :sales
# 	has_many   :orders
# 	has_many   :campaign_items
# 	has_many   :protos
# 	has_many   :providers_socials
# 	has_many   :socials, through: :providers_socials
# 	belongs_to :brand
# 	belongs_to :merchant
# 	belongs_to :region

# 	attr_accessor 	:menu

# 	enum payment_plan: [ :no_plan, :choice, :prime ]
# 	enum payment_event: [ :creation, :redemption ]

# #	-------------

# 	def city
# 		self.city_name
# 	end

# 	def city= name
# 		self.city_name = name
# 	end

# #	-------------

# 	def self.get_all
# 		unscoped.order("name ASC")
# 	end

# 	def self.allWithinBounds(bounds)
# 		puts bounds
# 		Provider.where(:latitude => (bounds[:botLat]..bounds[:topLat]), :longitude => (bounds[:leftLng]..bounds[:rightLng]))
# 	end

# #	-------------


# 	def redemption
# 		REDEMPTION_HSH[r_sys]
# 	end

# 	# def region
# 	# 	REGION_TO_TEXT[region_id]
# 	# end

# 	def biz_user
# 		BizUser.find(self.id)
# 	end

# #########   STATUS METHODS

# 	def short_image_url
# 		shorten_photo_url(image)
# 	end

# 	def live_int
# 		self.live ? "1" : "0"
# 	end

# 	def mode
# 	    if self.paused
# 	        return "paused"
# 	    else
# 	    	if self.live
# 	    	    return "live"
# 	    	else
# 	    	    return "coming_soon"
# 	    	end
# 	    end
# 	end

# 	def mode= mode_str
# 		case mode_str.downcase
# 		when "live"
# 			self.paused = false
# 			self.live   = true
# 		when "coming_soon"
# 			self.paused = false
# 			self.live   = false
# 		when "paused"
# 			self.paused = true
# 		else
# 			# cron job to fix the broken mode_str
# 			puts "#{self.name} #{self.id} was sent mode_str #{mode_str} - update mode broken"
# 		end
# 	end

# 	def deactivate
# 		self.paused = true
# 		self.live 	= false
# 		self.active = false
# 		if self.save
# 			true
# 		else
# 			false
# 		end
# 	end

# ##################

# 	def get_todays_credits
# 		self.orders.where("updated_at > ?", (Time.now - 1.day))
# 	end


# 	def sales_tax
# 		tax = super
# 		tax.nil? || tax.empty? ? "8" : tax
# 	end

# 	def sales_tax=(sales_tax)
# 		unless sales_tax.nil?
# 			sales_tax.gsub!('%', '')
# 			sales_tax.gsub!(' ', '')
# 		end
# 		super(sales_tax)
# 	end

# 	def location_fee(convert_these_cents=nil)
# 		r_cents = self.rate / 100.0
# 		if convert_these_cents
# 			(convert_these_cents * r_cents).to_i
# 		else
# 			r_cents
# 		end

# 	end

# ######   PHOTO GETTERS

# 	def get_photo default: true
# 		if default && image.blank?
# 			return MERCHANT_DEFAULT_IMG
# 		end
# 		image
# 	end

#     def get_logo
#         if photo_l.present?
#             photo_l
#         else
#             "http://res.cloudinary.com/drinkboard/image/upload/v1408401050/blank_logo_njwzxk.jpg"
#         end
#     end

# 	def get_logo_web
# 		self.photo_l
# 	end

# 	def get_photo_old
# 		if image.blank?
# 			if photo.blank?
# 				MERCHANT_DEFAULT_IMG
# 			else
# 				photo.url
# 			end
# 		else
# 			image
# 		end
# 	end

# private

#     def clear_www_cache
#         unless Rails.env.test? || Rails.env.development?
#             WwwHttpService.clear_merchant_cache
#         end
#     end

# 	def make_menu_string
# 	    MenuString.create(provider_id: self.id, data: "[]", menu: self.menu)
# 	end

# 	def add_region_name
# 		if self.region_id.present? && (self.region_name.nil? || self.region_id_changed?)
# 			region = Region.unscoped.where(id: self.region_id).first
# 			self.region_name = region.name if region.present?
# 		else
# 			self.region_name = nil if self.region_id.nil?
# 		end
# 	end

# end
# # == Schema Information
# #
# # Table name: providers
# #
# #  id              :integer         not null, primary key
# #  name            :string(255)     not null
# #  zinger          :string(255)
# #  description     :text
# #  address         :string(255)
# #  city            :string(32)
# #  state           :string(2)
# #  zip             :string(16)
# #  created_at      :datetime        not null
# #  updated_at      :datetime        not null
# #  phone           :string(255)
# #  sales_tax       :string(255)
# #  active          :boolean         default(TRUE)
# #  latitude        :float
# #  longitude       :float
# #  rate            :integer 		default(85)
# #  menu_is_live    :boolean         default(FALSE)
# #  brand_id        :integer
# #  building_id     :integer
# #  token           :string(255)
# #  tools           :boolean         default(FALSE)
# #  image           :string(255)
# #  merchant_id     :integer
# #  live            :boolean         default(FALSE)
# #  paused          :boolean         default(TRUE)
# #  pos_merchant_id :string(255)
# #  region_id       :integer
# #  r_sys           :integer         default(2)
# #  photo_l         :string(255)
# #  payment_plan    :integer         default(0)
# #

