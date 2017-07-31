class Book < ActiveRecord::Base
	include MoneyHelper
    include Formatters

    has_many :bookings
	belongs_to :merchant

    auto_strip_attributes :name, :zinger, :detail, :notes,
	    :member1, :member2, :member3, :member4,
		:member1_name, :member2_name, :member3_name, :member4_name,
    	:photo1, :photo2, :photo3, :photo4, :photo_banner, :photo_logo,
		:photo1_name, :photo2_name, :photo3_name, :photo4_name, :photo_banner_name, :photo_logo_name,
		:price1_name, :price2_name

	validates_presence_of :merchant, :name, :advance_days, :min_ppl, :max_ppl, :price1
	validates_numericality_of :tax_rate, greater_than_or_equal_to: 0, less_than_or_equal_to: 1, message: 'must be between 0 & 100'
	validates_numericality_of :tip_rate, greater_than_or_equal_to: 0, less_than_or_equal_to: 1, message: 'must be between 0 & 100'

	delegate :name, prefix: :merchant, to: :merchant, allow_nil: true
	delegate :list_serialize, prefix: :merchant, to: :merchant, allow_nil: true
	delegate :timezone, to: :merchant, allow_nil: true

	PRICE1_ID = 'pr_f1ab5595'
	PRICE2_ID = 'pr_d301c9bf'

# ---------------


    def price1_dollars
        display_money(cents: self.price1)
    end

    def price1_dollars= val
        self.price1 = currency_to_cents(val)
    end

    def price2_dollars
        display_money(cents: self.price2)
    end

    def price2_dollars= val
        self.price2 = currency_to_cents(val)
    end

   	def choose_price pid
		if pid == PRICE1_ID || pid == self.price1_name || pid.to_i == self.price1 || pid.to_i == 1
    		{ price: self.price1, title: self.price1_name, id: PRICE1_ID }.with_indifferent_access
    	elsif pid == PRICE2_ID || pid == self.price2_name || pid.to_i == self.price2 || pid.to_i == 2
    		{ price: self.price2, title: self.price2_name, id: PRICE1_ID }.with_indifferent_access
    	end
    end

	def price_total(price=self.price1)
		if tax_tip_included
			return price
		else
			price + tax_amount(price) + tip_amount(price)
		end
	end

	def tax_amount(amt=self.price1)
		(amt * tax_rate).round
	end

	def tax_amount_display(amt=self.price1)
		tax_tip_included ? 0 : tax_amount(amt)
	end

	def tip_amount(amt=self.price1)
		(amt * tip_rate).round
	end

	def tip_amount_display(amt=self.price1)
		tax_tip_included ? 0 : tip_amount(amt)
	end

	def tax_rate_display
		(self.tax_rate.to_f * 100).round(3)
	end

	def tax_rate_display= value
		self.tax_rate = (value.to_f / 100).round(4)
	end

	def tip_rate_display
		(self.tip_rate.to_f * 100).round(3)
	end

	def tip_rate_display= value
		self.tip_rate = (value.to_f / 100).round(4)
	end


# ---------------

	def self.find_with_token tkn
		if tkn.kind_of?(String) && tkn[0..5] == "#{BOOKING_ID}-"
			t = tkn.gsub("#{BOOKING_ID}-", '')
			id = t.split('-').first
			if id.to_i.to_s == id
				return find(id)
			end
		end
		raise ActiveRecord::RecordNotFound
	end

# ---------------

	def self.statuses
		['live', 'coming_soon']
	end


	def status= str
		str = str.to_s
		if Book.statuses.include?(str)
			super(str)
		else
			puts "Status is not available - try Book.statuses for options"
		end
	end

    def ccy
    	super || 'USD'
    end


# ---------------


    def get_photo
    	self.photo_banner || self.photo1 || self.photo2 || self.photo3 || self.photo4
    end

    def basic_serialize
		{
	    		# LIST OWNER DATA
	    	owner_type: 'Merchant',
	    	owner_id: self.merchant_id,
	        owner: merchant_list_serialize || { name: 'Merchant' },
	     		# LIST META DATA
	    	type: 'book', id: self.id, token: token,
	    	active: self.active, status: self.status,
	    	href: itsonme_url, api_url: api_url, shop_url: shop_url,
	        	# LIST PRESENTATION DATA
	    	name: self.name, zinger: self.zinger, detail: self.detail, notes: self.notes,
	        photo: self.get_photo, ccy: self.ccy,
	        advance_days: self.advance_days, min_ppl: self.min_ppl, max_ppl: self.max_ppl,
			duration_minutes: duration, duration_desc: duration_desc,
			tax_tip_included: self.tax_tip_included
   		}
    end

    def list_serialize
    	h = basic_serialize
    	h[:photos] = photos_serialize
    	h[:members] = members_serialize
    	h[:prices] = prices_serialize
    	unless tax_tip_included
	    	h.merge!({ tax_name: self.tax_name, tax_rate: tax_rate_display, tip_name: self.tip_name, tip_rate: tip_rate_display })
		end
    	h
    end
    alias_method :serialize, :list_serialize

	def members_serialize
		ary = []
		ary << { title: self.member1, name: self.member1_name } if self.member1
		ary << { title: self.member2, name: self.member2_name } if self.member2
		ary << { title: self.member3, name: self.member3_name } if self.member3
		ary << { title: self.member4, name: self.member4_name } if self.member4
		ary
	end

	def photos_serialize
		ary = []
		ary << { url: self.photo_banner, detail: self.photo_banner_name, type: 'banner' } if self.photo_banner
		ary << { url: self.photo_logo, detail: self.photo_logo_name, type: 'logo' } if self.photo_logo
		ary << { url: self.photo1, detail: self.photo1_name, type: 'carousel' } if self.photo1
		ary << { url: self.photo2, detail: self.photo2_name, type: 'carousel' } if self.photo2
		ary << { url: self.photo3, detail: self.photo3_name, type: 'carousel' } if self.photo3
		ary << { url: self.photo4, detail: self.photo4_name, type: 'carousel' } if self.photo4
		ary
	end

    def prices_serialize
    	ary = []
    	ary << { price_total: price_total(self.price1), price: self.price1, ccy: self.ccy, title: self.price1_name, id: PRICE1_ID } if self.price1
    	ary << { price_total: price_total(self.price2), price: self.price2, ccy: self.ccy, title: self.price2_name, id: PRICE2_ID } if self.price2
    	ary
    end


# ---------------


	def duration
		# default is 120
		# units is minutes
		super
	end

	def duration_desc
		x = duration
		return '' if x.to_s.blank?
		if x < 91
			"#{x} minute".pluralize(x)
		else
			hours = (x / 60.0).round(1)
			hours = hours.to_i if hours.to_i == hours
			"#{hours} hour".pluralize(hours)
		end
	end

    def earliest_booking_date
    	# today in merchant timezone
    	# plus advance days
    	# that day is book by - event date
    	today = TimeGem.change_time_to_zone(DateTime.now, timezone)
    	today + (self.advance_days || 0).days
    end


# ---------------


    def shop_url
        itsonme_url
    end

    def api_url
    	"#{APIURL}/menu_items/#{token}/book"
    end

    def itsonme_url
        "#{CLEAR_CACHE}/share/menu_items/#{token}/book"
    end


# ---------------

	def name= str
		super(str.to_s.titleize)
	end

	def client
		Client.booking(self.id)
	end

	def token
		"#{BOOKING_ID}-#{self.id}-#{make_slug(self.name)}"
	end


# ---------------



# ---------------




private


end