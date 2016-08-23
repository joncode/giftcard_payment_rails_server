class MenuItem < ActiveRecord::Base
	include ShortenPhotoUrlHelper
    include Formatters

#   -------------

	belongs_to :section
	belongs_to :menu

#   -------------

	after_save :set_token

#   -------------

	validates_uniqueness_of :token, allow_blank: true

#   -------------


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

    def serialize_to_app(quantity=nil)
        item_hash = self.serializable_hash only: [ :photo, :detail, :price, :price_cents, :price_promo_cents, :price_promo, :pos_item_id ]
        item_hash["item_id"]   = self.id
        item_hash["item_name"] = self.name
        if quantity.present?
            item_hash['quantity'] = quantity
        end
        return item_hash
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
	    	type: 'menu_item', id: self.id,
	    	href: itsonme_url, api_url: api_url, active: self.active,
	        	# LIST PRESENTATION DATA
	    	name: self.name, zinger: self.section_name, detail: self.detail,
	        photo: self.photo, ccy: self.ccy, price: self.price
   		}
    end

    def api_url
    	"#{APIURL}/menu_items/#{self.token}"
    end

    def itsonme_url
        "#{CLEAR_CACHE}/share/menu_items/#{self.token}"
    end

#   -------------

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

    def owner
        if mi = self.menu
            mi.owner
        else
            nil
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
        if self.token.nil?
            self.update_column(:token, make_url_string("#{self.id}_#{self.name}"))
        end
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

