class Client < ActiveRecord::Base
	include Utility

#	-------------

	before_validation :create_unique_application_key
	before_validation :create_unique_url_name

#	-------------

    validates_uniqueness_of :url_name, :application_key

#	-------------

	enum ecosystem: [ :full, :client, :company ]
	enum platform: [:ios, :android, :web_menu, :kiosk, :landing_page]



#	-------------

	def content_merchants

		if self.client?
			client_contents.include(:merchants).include(:providers).where(client_id: self.id, content_type: 'Merchant')
		elsif self.company?
			client_contents.include(:merchants).include(:providers).where(company_id: self.company_id, company_type: self.company_type, content_type: 'Merchant')
		else
			# call normal query for table
		end

	end

	def content_providers

		if self.client?
			client_contents.include(:merchants).where(client_id: self.id, content_type: 'Merchant')
		elsif self.company?
			client_contents.include(:merchants).where(company_id: self.company_id, company_type: self.company_type, content_type: 'Merchant')
		else
			# call normal query for table
		end

	end

	def content_users

		if self.client?
			client_contents.include(:users).where(client_id:  self.id, content_type: 'User')
		elsif self.company?
			client_contents.include(:users).where(company_id:  self.company_id, company_type: self.company_type, content_type: 'Merchant')
		else
			# call normal query for table
		end

	end

	def content_gifts

		if self.client?
			client_contents.include(:gifts).where(client_id: self.id, content_type: 'Gift')
		elsif self.company?
			client_contents.include(:gifts).where(company_id:  self.company_id, company_type: self.company_type, content_type: 'Merchant')
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
