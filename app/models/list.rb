class List < ActiveRecord::Base
	include Formatters


    auto_strip_attributes :name, :zinger, :detail
    auto_strip_attributes :photo, :logo, unshorten_photo_url: true

#   -------------

	before_validation :set_token_from_name

#   -------------

	validates_presence_of :token, :name#, :owner_type, :owner_id
	validates_uniqueness_of :token, conditions: -> { where(active: true) }

#   -------------

	before_save :set_item_type
	before_save :set_total_items
	before_save :set_template

#   -------------

	has_many :clients
	has_many :list_graphs, dependent: :destroy
	has_many :lists, through: :list_graphs, source: :item, source_type: 'List'
	has_many :merchants, through: :list_graphs, source: :item, source_type: 'Merchant'
	has_many :menu_items, through: :list_graphs, source: :item, source_type: 'MenuItem'
	has_many :books, through: :list_graphs, source: :item, source_type: 'Book'
	belongs_to :owner, polymorphic: true

	attr_accessor :offset, :gifts

#   -------------

	def self.find_by_owner owner
		if owner.kind_of?(Client)
			if owner.client?
				includes(:list_graphs).find_by owner_id: owner.id, owner_type: owner.class.to_s
			else
				partner = owner.partner
				includes(:list_graphs).find_by owner_id: partner.id, owner_type: partner.class.to_s
			end
		else
			includes(:list_graphs).find_by owner_id: owner.id, owner_type: owner.class.to_s
		end
	end

	def self.item_types
		['list', 'merchant', 'menu_item', 'gift', 'book']
	end

	def self.templates
		item_types.map(&:pluralize)
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

	def offset
		return 0 if @offset.nil?
	end

	def items
		if self.item_type == 'merchant'
			merchants
		elsif self.item_type == 'book'
			books
		elsif self.item_type == 'menu_item'
			menu_items
		elsif self.item_type == 'list'
			lists
		elsif self.item_type == 'gift'
			gifts
		else
			[]
		end
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

	def sort_items old_ind, new_ind
			# Redux style re-sorter
		oc = Array.new(self.list_graphs)
			# remove item from old array and shorten array
		item = oc[old_ind]
		oc[old_ind] = nil
		oc.compact!
			# make arrays out of pieces before/after new insert location
		new1 = oc[0 ... new_ind]
		new2 = oc[(new_ind) .. oc.length]
			# insert item in between
		newAry = new1 + [item] + new2

			# update all positions based on new array indexes
		newAry.each_with_index do |lg, index|
			if lg.position != index
				lg.update(position: index)
			end
		end
		return self
	end

	def alphabetize key=:name
		# alphabetize any list based on key
		alph_ary = self.items.order(key => :asc)

		alph_ary.each_with_index do |item, num|
			lg = self.list_graphs.where(item_id: item.id, item_type: item.class.to_s).where.not(position: num).first
			lg.update(position: num) if lg
		end
	end

	def remove_inactive_items
		self.list_graphs.each do |lg|
				# ducktype method
			list_item = lg.item
			if list_item.nil? || list_item.active_live?
				lg.destroy
			end
		end
		self
	end


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
		self.token = make_slug(self.name) if self.token.nil?
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
		if List.item_types.include?(self.item_type)
			self.template = self.item_type.pluralize
		else
			self.template = nil
		end
		true
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
