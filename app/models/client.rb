class Client < ActiveRecord::Base
	extend ClientMaker
	include Utility

#	-------------

    auto_strip_attributes :name, :detail, :download_url, :url_name

#	-------------

	before_validation :create_unique_application_key, on: :create
	before_validation :set_application_key_for_epson

#	-------------

    after_save :clear_cache

#	-------------

    validates_presence_of :name, :url_name, :application_key, :partner_id, :partner_type
    validates_uniqueness_of :url_name, :application_key, scope: :active
    validates_uniqueness_of :download_url, scope: [:active, :platform], allow_nil: true

#	-------------

	has_many :gifts
	has_many :redemptions

	belongs_to :list
	belongs_to :partner, polymorphic: true

	enum ecosystem: [ :full, :client, :partner ]
	enum platform: [ :ios, :android, :menu_widget, :kiosk, :landing_page, :menu_facebook, :redemption, :clover, :epson ]
	enum data_type: [ :merchant, :region, :overview, :menu, :promo, :unknown, :list, :merchant_signup, :book, :books ]

# return Merchant.find_by_sql("SELECT merchants.* FROM contents , merchants WHERE contents.client_id IS NULL AND contents.partner_type = 'Affiliate' AND contents.partner_id = 29
	# AND contents.content_type = 'Merchant' AND merchants.id = contents.content_id")

#	-------------   INSTANCE METHODS

	def click
		self.increment!(:clicks)
	end

	def contents content_symbol
		if self.full?
			if block_given?
				return yield(self)
			else
				return content_symbol.to_s.singularize.capitalize.constantize.index
			end
		end

			# content_symbol = :gifts, :merchants, :regions, :users
		constant_symbol = content_symbol.to_s.singularize.capitalize
		client_id_query = "contents.client_id "
		if self.client?
			client_id_query += " = #{self.id} "
		elsif self.partner?
			client_id_query += " IS NULL "
		end
		query = "SELECT #{content_symbol}.* FROM contents , #{content_symbol} \
WHERE #{client_id_query} AND contents.partner_type = '#{self.partner_type}' \
AND contents.partner_id = #{self.partner_id} AND contents.content_type = '#{constant_symbol}' \
AND #{content_symbol}.id = contents.content_id"
		return constant_symbol.constantize.find_by_sql(query)
	end

	def content= obj
		if obj.class.to_s.match(/Gift/)
			class_name = 'Gift'
		else
			class_name = obj.class.to_s.singularize.capitalize
		end
		client_content = ClientContent.new(partner_id:  self.partner_id, partner_type: self.partner_type,
			content_type: class_name, content_id: obj.id)
		if self.client?
			client_content.client_id = self.id
		else
			client_content.client_id = nil
		end

		# binding.pry
		if client_content.save
			if obj.class.to_s == 'Merchant' && obj.city_id
				if r = Region.where(id: obj.city_id).first
					self.content = r
				end
			end
		end
		return client_content
	end

	def remove_content= obj
		if self.client?
			client_content = ClientContent.where(client_id: self.id, content_type: obj.class.to_s,
				content_id: obj.id ).first
		else
			client_content = ClientContent.where(client_id: nil, partner_id:  self.partner_id,
				partner_type: self.partner_type, content_type: obj.class.to_s, content_id: obj.id).first
		end

		client_content.destroy if client_content
	end

#	-------------  CLASS METHODS

	def self.booking(book_id)
		where(data_id: book_id, data_type: 8).first
	end

	def self.legacy_client platform=nil, agent_str=''
        if platform == 'android' || agent_str.match(/Android/)
            find(ANDROID_CLIENT_ID)
        elsif platform == 'ios' || agent_str.match(/iPhone/)
        	find(IOS_CLIENT_ID)
        else
        	find(IOS_CLIENT_ID)
        end
	end

	def self.find_with_url ary_of_slugs
		ary_of_slugs = [ary_of_slugs] if ary_of_slugs.kind_of?(String)
		ary_of_slugs = ary_of_slugs.reject(&:blank?)
		sql = "active = 't' AND url_name ilike "
		ary_of_slugs.each_with_index do |slug, index|
			next if slug.blank?
			if index == 0
				sql += " '#{slug}%' OR download_url ilike '#{slug}%' "
			else
				sql += " OR url_name ilike '#{slug}%' OR download_url ilike '#{slug}%' "
			end
		end
		menu_widget.where(active: true).where(sql)
	end


private


	def set_application_key_for_epson
		if self.epson? && (self.application_key.nil? || self.application_key.length > 28)
			create_unique_application_key
		end
	end

	def create_unique_application_key
		length = self.epson? 23 : 42
		self.application_key = UniqueIdMaker.secure_url_safe(self.class, :application_key, 'cl_', length)
	end

    def clear_cache
        unless Rails.env.test? || Rails.env.development?
            RedisWrap.clear_client_cache(self.id)
            # WwwHttpService.clear_merchant_cache
        end
    end
end
