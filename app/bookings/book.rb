class Book < ActiveRecord::Base
	include MoneyHelper
    include Formatters

    has_many :bookings

    auto_strip_attributes :name, :zinger, :detail, :notes,
	    :member1, :member2, :member3, :member4,
		:member1_name, :member2_name, :member3_name, :member4_name,
    	:photo1, :photo2, :photo3, :photo4,
		:photo1_name, :photo2_name, :photo3_name, :photo4_name,
		:price1_name, :price2_name

	validates_presence_of :name, :merchant_id, :advance_days, :min_ppl, :max_ppl, :price1

	belongs_to :merchant


	def price_desc price_unit
		if price_unit.to_i == self.price1
			self.price1_name
		else
			self.price2_name
		end
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

	def self.statuses
		['live', 'coming_soon']
	end

# ---------------

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

	def merchant_name
		return self.merchant ? self.merchant.name : 'No Merchant'
	end

	def merchant_list_serialize
		m = self.merchant
		return { name: 'Merchant' } if m.nil?
		m
	end

    def get_photo
    	self.photo1 || self.photo2 || self.photo3 || self.photo4
    end

    def basic_serialize
		{
	    		# LIST OWNER DATA
	    	owner_type: 'Merchant',
	    	owner_id: self.merchant_id,
	        owner: merchant_list_serialize,
	     		# LIST META DATA
	    	type: 'book', id: self.id, token: token,
	    	active: self.active, status: self.status,
	    	href: itsonme_url, api_url: api_url, shop_url: shop_url,
	        	# LIST PRESENTATION DATA
	    	name: self.name, zinger: self.zinger, detail: self.detail, notes: self.notes,
	        photo: self.get_photo, ccy: self.ccy,
	        advance_days: self.advance_days, min_ppl: self.min_ppl, max_ppl: self.max_ppl,
			duration_minutes: duration, duration_desc: duration_desc
   		}
    end

    def list_serialize
    	h = basic_serialize
    	h[:photos] = photos_serialize
    	h[:members] = members_serialize
    	h[:prices] = prices_serialize
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
		ary << { url: self.photo1, detail: self.photo1_name } if self.photo1
		ary << { url: self.photo2, detail: self.photo2_name } if self.photo2
		ary << { url: self.photo3, detail: self.photo3_name } if self.photo3
		ary << { url: self.photo4, detail: self.photo4_name } if self.photo4
		ary
	end

    def prices_serialize
    	ary = []
    	ary << { price: self.price1, ccy: self.ccy, title: self.price1_name } if self.price1
    	ary << { price: self.price2, ccy: self.ccy, title: self.price2_name } if self.price2
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
    	today = in_timezone(DateTime.now)
    	today + (self.advance_days || 0).days
    end

	def timezone
		self.merchant ? self.merchant.time_zone : "Pacific Time (US & Canada)"
	end

	def in_timezone datetime
    	datetime.in_time_zone(timezone)
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