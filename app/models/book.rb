class Book < ActiveRecord::Base
	include MoneyHelper
    include Formatters

    auto_strip_attributes :name, :zinger, :detail, :notes

	validates_presence_of :name

	belongs_to :merchant

	before_save :tighten_up_json

	attr_accessor :price_dollars, :price_wine_dollars, :chef, :sommelier, :general_manager, :other,
		:photo1, :photo2, :photo3, :photo4


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

	def merchant_list_serialize
		m = self.merchant
		return { name: 'Merchant Name' } if m.nil?
		m
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
	        photo: self.get_photo, ccy: self.ccy, price: self.price, price_wine: self.price_wine,
	        advance_days: self.advance_days, min_ppl: self.min_ppl, max_ppl: self.max_ppl
   		}
    end

    def prices_serialize
    	[
    		{ price: self.price, ccy: self.ccy, title: 'Price without Wine'},
    		{ price: self.price_wine, ccy: self.ccy, title: 'Price with Wine'}
    	]
    end

    def list_serialize
    	h = basic_serialize
    	h[:photos] = photos_serialize
    	h[:members] = members_serialize
    	h[:prices] = prices_serialize
    	h
    end
    alias_method :serialize, :list_serialize


    def shop_url
        itsonme_url
    end

    def api_url
    	"#{APIURL}/menu_items/#{token}/book"
    end

    def itsonme_url
        "#{CLEAR_CACHE}/share/menu_items/#{token}/book"
    end

    def get_photo
    	self.photos.each do |name, photo_url|
    		if photo_url.blank?
    			next
    		else
    			return photo_url
    			break
    		end
    	end
    	nil
    end

    def photo
    	get_photo
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

	def price_dollars
		display_money(cents: self.price)
	end

	def price_dollars= val
		self.price = currency_to_cents(val)
	end

	def price_wine_dollars
		display_money(cents: self.price_wine)
	end

	def price_wine_dollars= val
		self.price_wine = currency_to_cents(val)
	end


# ---------------


	def get_member_key key
		return nil if self.members.nil?
		self.members[key]
	end

	def set_member_key key, str
		str = str.to_s.strip
		if self.members.nil?
			h = { key => str }
		else
			h = self.members
			h[key] = str.strip
		end
		self.members = h
	end

	def chef
		get_member_key 'chef'
	end

	def chef= str
		set_member_key 'chef', str
	end

	def sommelier
		get_member_key 'sommelier'
	end

	def sommelier= str
		set_member_key 'sommelier', str
	end

	def general_manager
		get_member_key 'general_manager'
	end

	def general_manager= str
		set_member_key 'general_manager', str
	end

	def other
		get_member_key 'other'
	end

	def other= str
		set_member_key 'other', str
	end

	def members_serialize
		ps = self.members
		ary = []
		ps.each do |k,v|
			ary << { name: v, title: k.titleize }
		end
		ary
	end

# ---------------


	# def method_missing(method_name)
	# 	puts "#{method_name}"
	# 	str = method_name.to_s
	# 	if str.match(/photo/)
	# 		get_photo_key(method_name)
	# 	end
	# end

	def get_photo_key key
		return nil if self.photos.nil?
		self.photos[key]
	end

	def set_photo_key key, photo_url
		photo_url = photo_url.to_s.strip
		if self.photos.nil?
			h = { key => photo_url }
		else
			h = self.photos
			h[key] = photo_url
		end
		self.photos = h
	end

	def photos_serialize
		ps = self.photos
		ary = []
		ps.each do |k,v|
			ary << { url: v, detail: "#{k} detail" }
		end
		ary
	end

	def photo1
		get_photo_key 'photo1'
	end

	def photo1= photo_url
		set_photo_key 'photo1', photo_url
	end

	def photo2
		get_photo_key 'photo2'
	end

	def photo2= photo_url
		set_photo_key 'photo2', photo_url
	end

	def photo3
		get_photo_key 'photo3'
	end

	def photo3= photo_url
		set_photo_key 'photo3', photo_url
	end

	def photo4
		get_photo_key 'photo4'
	end

	def photo4= photo_url
		set_photo_key 'photo4', photo_url
	end


private

    def members_tight
    	self.members.select{ |k,v| !v.blank? }
    end

    def photos_tight
    	self.photos.select{ |k,v| !v.blank? }
    end

	def tighten_up_json
		if self.members.present?
			self.members = members_tight
		end
		if self.photos.present?
			self.photos = photos_tight
		end
	end

end