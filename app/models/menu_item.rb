class MenuItem < ActiveRecord::Base
	include ShortenPhotoUrlHelper
    include Formatters
    include MoneyHelper

#   -------------

    has_many :gift_items
	belongs_to :section
	belongs_to :menu

#   -------------

    before_save :set_cents

	after_save :set_token

#   -------------

	validates_uniqueness_of :token, allow_blank: true

#   -------------

    def price
        puts 'PRICE WRAP'
        str = display_money(cents: self.price_cents)
        if price_o != str
            puts "PRICE INCORRECT #{str} != #{price_o} 500 Internal "
        end
        str
    end

    def price_o
        self.read_attribute(:price)
    end

    def price_s
        display_money(cents: self.price_cents, ccy: self.ccy, delimiter: ',')
    end

	def self.get_voucher_for_amount(menu_id, amount='40')
		voucher_section = Section.get_voucher(menu_id)
		item = where(price: amount.to_s, section_id: voucher_section.id).first
		if item.nil?
			MenuItem.create(price: amount.to_s,
				menu_id: menu_id,
				section_id: voucher_section.id,
				name: "$#{amount.to_s} Gift Voucher",
				detail: "The entire gift amount must be used at one time. Unused portions of this gift cannot be saved, transferred, or redeemed for cash.",
				standard: false,
				promo: false
			)
		else
			item
		end
	end

	def photo_url
		unshorten_photo_url self.photo
	end

    def serialize_to_app
        item_hash = self.serializable_hash only: [ :detail, :price, :price_cents, :photo, :ccy, :pos_item_id ]
        item_hash["item_id"]   = self.id
        item_hash["item_name"] = self.name
        return item_hash
    end

    def serialize_with_quantity quantity=1
        hash = serialize_to_app
        hash["quantity"]    = quantity.to_i
        hash["price_promo"] = self.price_promo
        hash["price_promo_cents"] = self.price_promo_cents
        hash["section"]     = self.section.name
        hash
    end

    def section_name
    	if sec = section
    		sec.name
    	end
    end

    def list_serialize
		{
	    		# LIST OWNER DATA
	    	owner_type: self.owner_type, owner_id: self.owner_id,
	    	owner: self.owner_list_serialize,
	     		# LIST META DATA
	    	type: 'menu_item', id: self.id, active: self.active,
	    	href: itsonme_url, api_url: api_url, shop_url: shop_url,
	        	# LIST PRESENTATION DATA
	    	name: self.name, zinger: self.section_name, detail: self.detail,
	        photo: self.photo, ccy: self.ccy, price: self.price
   		}
    end

    def shop_url
        owner = self.owner
        if owner.kind_of?(Merchant)
            region = Region.unscoped.where(id: owner.city_id).first
        else
            m = Merchant.where(menu_id: self.menu_id).first
            region = Region.unscoped.where(id: m.city_id).first
        end
        return nil if region.nil?
        city_token = region.token
        merchant_token = make_url_string(owner.name)
        "#{CLEAR_CACHE}/shop/#{city_token}/#{merchant_token}/#{self.id}"
    end

    def api_url
    	"#{APIURL}/menu_items/#{self.token}"
    end

    def itsonme_url
        "#{CLEAR_CACHE}/share/menu_items/#{self.token}"
    end

#   -------------

    def owner
        if mi = self.menu
            mi.owner
        else
            nil
        end
    end

    def owner_type
    	if o = owner
    		o.class.name
    	end
    end

    def owner_id
    	if o = owner
    		o.id
    	end
    end

    def owner_name
        if o = owner
            o.name
        else
            ''
        end
    end

    def owner_list_serialize
    	if o = owner
    		o.list_serialize
    	else
    		{}
    	end
    end

#   -------------

    def set_token
        if self.token.nil? || (self.token != make_slug("#{self.id}-#{self.name}"))
            self.update_column(:token, make_slug("#{self.id}-#{self.name}"))
        end
    end

    def set_cents
        self.price_cents = currency_to_cents self.price
        if self.price_promo.blank?
            self.price_promo = nil
        end
        self.price_promo_cents = currency_to_cents self.price_promo
    end

end
# == Schema Information
#
# Table name: menu_items
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  section_id  :integer
#  menu_id     :integer
#  detail      :text
#  price       :string(255)
#  photo       :string(255)
#  position    :integer
#  active      :boolean         default(TRUE)
#  price_promo :string(255)
#  standard    :boolean         default(FALSE)
#  promo       :boolean         default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#

