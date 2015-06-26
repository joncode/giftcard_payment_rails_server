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
	enum platform: [:ios, :android, :web_menu, :kiosk, :landing_page]



#	-------------

	def contents content_symbol
			# content_cymbol = :gifts, :merchants, :regions, :users, :providers
		if self.client?
			ClientContent.includes(content_symbol).where(client_id: self.id, content_type: content_symbol.to_s.singularize.capitalize)
		elsif self.partner?
			ClientContent.includes(content_symbol).where(client_id: nil, partner_id: self.partner_id, partner_type: self.partner_type, content_type: content_symbol.to_s.singularize.capitalize)
		else
			[]
		end

	end

	def content= obj
		client_content = ClientContent.new(partner_id:  self.partner_id, partner_type: self.partner_type, content_type: obj.class.to_s, content_id: obj.id)
		if self.client?
			client_content.client_id = self.id
		else
			client_content.client_id = nil
		end

		if client_content.save
			if obj.class.to_s == 'Merchant' && obj.city_id
				if r = Region.where(id: obj.city_id).first
					self.content = r
				end
			end
		end
	end


private

	def create_unique_application_key
		self.application_key = create_session_token
	end

end
