class Client < ActiveRecord::Base
	include Utility

#	-------------

	before_validation :create_unique_application_key, on: :create

#	-------------

    validates_presence_of :name, :url_name, :application_key, :partner_id, :partner_type
    validates_uniqueness_of :url_name, :application_key

#	-------------

	belongs_to :partner,  polymorphic: true

	enum ecosystem: [ :full, :client, :partner ]
	enum platform: [ :ios, :android, :menu_widget, :kiosk, :landing_page, :menu_facebook ]
	enum data_type: [ :merchant, :region, :overview, :menu, :promo ]

# return Merchant.find_by_sql("SELECT merchants.* FROM contents , merchants WHERE contents.client_id IS NULL AND contents.partner_type = 'Affiliate' AND contents.partner_id = 29
	# AND contents.content_type = 'Merchant' AND merchants.id = contents.content_id")

#	-------------

	def contents content_symbol
		if self.full?
			return yield(self)
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
		client_content = ClientContent.new(partner_id:  self.partner_id, partner_type: self.partner_type, content_type: class_name, content_id: obj.id)
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
	end

	def remove_content= obj
		if self.client?
			client_content = ClientContent.where(client_id: self.id, content_type: obj.class.to_s, content_id: obj.id ).first
		else
			client_content = ClientContent.where(client_id: nil, partner_id:  self.partner_id, partner_type: self.partner_type, content_type: obj.class.to_s, content_id: obj.id).first
		end

		client_content.destroy if client_content
	end

#	-------------

	def self.legacy_client platform, agent_str=''
        if platform == 'android' || agent_str.match(/Android/)
            self.find(ANDROID_CLIENT_ID)
        elsif platform == 'ios' || agent_str.match(/iPhone/)
        	self.find(IOS_CLIENT_ID)
        else
        	self.find(WBG_CLIENT_ID)
        end
	end


private

	def create_unique_application_key
		self.application_key = create_session_token
	end

end
