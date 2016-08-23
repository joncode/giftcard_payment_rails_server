class List < ActiveRecord::Base
	include Formatters

	attr_accessor :offset

	before_validation :set_token_from_name

#   -------------

	validates_presence_of :token, :name, :owner_type, :owner_id
	validates_uniqueness_of :token, allow_blank: false

	has_many :list_graphs
	belongs_to :owner, polymorphic: true

#   -------------

	def self.find_by_owner owner
		if owner.kind_of?(Client)
			if owner.client?
				find_by owner_id: owner.id, owner_type: owner.class.to_s
			else
				partner = owner.partner
				find_by owner_id: partner.id, owner_type: partner.class.to_s, token: 'master'
			end
		else
			find_by owner_id: owner.id, owner_type: owner.class.to_s
		end
	end

#   -------------

	def as_json args=nil
		{
	    		# LIST OWNER DATA
	    	owner_type: self.owner_type, owner_id: self.owner_id,
	     		# LIST META DATA
	    	type: type, list_id: list_id, id: self.id, token: self.token,
	    	href: href, active: self.active,
	        	# LIST PRESENTATION DATA
	    	template: self.template, name: self.name, zinger: self.zinger, detail: self.detail,
	        photo: self.photo, logo: self.logo, item_type: self.item_type,
	        	# PAGINATION
	        total_items: total_items, item_count: item_count, offset: offset,
	        prev: prev_offset, next: next_offset,
	        	# ARRAY
	        items: items.serialize_objs(:list)
   		}
	end

#   -------------

	def offset
		return 0 if @offset.nil?
	end

	def items
		list_graphs.map(&:item)
	end

	def item_count
		@item_count ||= items.length
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

	def self.index
		limit(100)
	end

	def set_token_from_name
		self.name ||= "List #{self.owner.name} #{rand(983741)}"
		self.token = "#{make_url_string(self.name)}"
	end

#   -------------

	def list_id
		self.id
	end

	def type
		'list'
	end

	def href
		"https://api.itson.me/web/v3/lists/#{self.token}"
	end

	def destroy
			# DO NOT DELETE RECORDS
		update_column(:active, false)
	end

#   -------------

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
