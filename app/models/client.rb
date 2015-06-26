class Client < ActiveRecord::Base
	include Utility

#	-------------

	before_validation :create_unique_application_key
	before_validation :create_unique_url_name

#	-------------

    validates_uniqueness_of :url_name, :application_key

#	-------------

	enum ecosystem: [ :full, :client, :partner ]
	enum platform: [:ios, :android, :web_menu, :kiosk, :landing_page]



#	-------------

	def content_merchants

		if self.client?
			client_contents.include(:merchants).include(:providers).where(client_id: self.id, content_type: 'Merchant')
		elsif self.partner?
			client_contents.include(:merchants).include(:providers).where(partner_id: self.partner_id, partner_type: self.partner_type, content_type: 'Merchant')
		else
			# call normal query for table
		end

	end

	def content_providers

		if self.client?
			client_contents.include(:merchants).where(client_id: self.id, content_type: 'Merchant')
		elsif self.partner?
			client_contents.include(:merchants).where(partner_id: self.partner_id, partner_type: self.partner_type, content_type: 'Merchant')
		else
			# call normal query for table
		end

	end

	def content_users

		if self.client?
			client_contents.include(:users).where(client_id:  self.id, content_type: 'User')
		elsif self.partner?
			client_contents.include(:users).where(partner_id:  self.partner_id, partner_type: self.partner_type, content_type: 'Merchant')
		else
			# call normal query for table
		end

	end

	def content_gifts

		if self.client?
			client_contents.include(:gifts).where(client_id: self.id, content_type: 'Gift')
		elsif self.partner?
			client_contents.include(:gifts).where(partner_id:  self.partner_id, partner_type: self.partner_type, content_type: 'Merchant')
		else
			# call normal query for table
		end

	end

private

	def create_unique_application_key
		create_session_token
	end

	def create_unique_url_name

	end

end
