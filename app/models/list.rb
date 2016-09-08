class List < ActiveRecord::Base
	include Formatters


    auto_strip_attributes :name, :zinger, :detail
    auto_strip_attributes :photo, :logo, unshorten_photo_url: true

#   -------------

	before_validation :set_token_from_name

#   -------------

	validates_presence_of :token, :name, :owner_type, :owner_id
	validates_uniqueness_of :token, conditions: -> { where(active: true) }

#   -------------

	before_save :set_item_type
	before_save :set_total_items
	before_save :set_template

#   -------------

	has_many :list_graphs, dependent: :destroy
	belongs_to :owner, polymorphic: true

	attr_accessor :offset

#   -------------

	def self.find_by_owner owner
		if owner.kind_of?(Client)
			if owner.client?
				find_by owner_id: owner.id, owner_type: owner.class.to_s
			else
				partner = owner.partner
				find_by owner_id: partner.id, owner_type: partner.class.to_s
			end
		else
			find_by owner_id: owner.id, owner_type: owner.class.to_s
		end
	end

	def self.templates
		['lists', 'merchants', 'menu_items']
	end

	def self.index
		where(active: true).limit(100)
	end

#   -------------

	def list_serialize
		{
	    		# LIST OWNER DATA
	    	owner_type: self.owner_type, owner_id: self.owner_id,
	     		# LIST META DATA
	    	type: type, list_id: list_id, id: self.id, token: self.token,
	    	href: itsonme_url, api_url: api_url, active: self.active,
	        	# LIST PRESENTATION DATA
	    	template: self.template, name: self.name, zinger: self.zinger, detail: self.detail,
	        photo: self.photo, logo: self.logo, item_type: self.item_type,
	        	# PAGINATION
	        total_items: total_items
   		}
	end

	def as_json(*args)
		list_serialize.merge({item_count: item_count, offset: offset,
	        prev: prev_offset, next: next_offset,
	        	# ARRAY
	        items: items.serialize_objs(:list)
   		})
	end

#   -------------

	def token
		super || "#{make_url_string(self.name)}"
	end

	def offset
		return 0 if @offset.nil?
	end

	def items
		list_graphs.map(&:item)
	end

	def item_count
		@total_items ||= items.length
	end

	def total_items
		@total_items ||= items.length
	end

	def prev_offset
		return nil if offset == 0
	end

	def next_offset
		return nil if total_items >= (item_count + offset)
		"https://api.itson.me/lists/#{self.token}?action=next&offset=#{self.offset}"
	end

#   -------------



#   -------------

	def list_id
		self.id
	end

	def type
		'list'
	end

    def itsonme_url
        "#{CLEAR_CACHE}/share/lists/#{self.token}"
    end

	def api_url
		"#{APIURL}/lists/#{self.token}"
	end

	def destroy
			# DO NOT DELETE RECORDS
		update_column(:active, false)
	end

#   -------------

	def get_photo
		self.photo
	end


private

	def set_token_from_name
		self.token = "#{make_slug(self.name)}" if self.token.nil?
	end

	def set_item_type
		if self.item_type.nil? && items.length > 0
			self.item_type = items.first.class.name.underscore
		end
	end

	def set_total_items
		self.total_items = total_items
	end

	def set_template
		return true unless self.template.nil?
		if self.item_type == 'list'
			self.template = 'lists'
		elsif self.item_type == 'menu_item'
			self.template = 'menu_items'
		else
			self.template = 'merchants'
		end
	end

end


# List

#     {
#     		# LIST OWNER DATA
#     	onwer_type: ["User", "Client", "Merchant", "Affiliate", "List" ], owner_id: /id of owner/
#      		# LIST META DATA
#     	type: 'list', list_id: 235, id: 235, token: 'list-token',  href: 'https://api.itson.me/web/v3/lists/list-token', active: true,
#         	# LIST PRESENTATION DATA
#     	template: 'merchants', name: 'List Name', zinger: 'longer text about this list', detail: 'paragraph about list',
#         photo: /photo_url/, logo: /logo_url/, item_type: 'merchants',
#         	# PAGINATION
#         total_items: 20, item_count: 10, offset: 0, prev: nil, next: 'https://api.itson.me/lists/list-token?action=next&offset=10',
#         	# ARRAY
#         items: [/array_of_items/]
#    	}
