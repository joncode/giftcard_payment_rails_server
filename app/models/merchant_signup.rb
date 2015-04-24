class MerchantSignup < ActiveRecord::Base
	include ActionView::Helpers::NumberHelper

	validates_presence_of  :venue_name, :venue_url, :point_of_sale_system, :name, :email
	validates :email , format: { with: VALID_EMAIL_REGEX }, allow_blank: :true
	validates :phone , format: { with: VALID_PHONE_REGEX }, allow_blank: :true
	validates_length_of :name,      :maximum => 100
	validates_length_of :position,  :maximum => 100
	validates_length_of :venue_name,:maximum => 100
	validates_length_of :venue_url, :maximum => 100
	validates_length_of :address, 	:maximum => 500
	validates_length_of :message,   :maximum => 500
	validates_length_of :point_of_sale_system,  :maximum => 100

	def email_body
		str  = "\nNAME:#{self.name} at EMAIL:#{self.email} would like to set up"
		str += "\nVENUE NAME:#{self.venue_name}\nVENUE URL: #{self.venue_url}\nPOS system: #{self.point_of_sale_system}"
		if self.phone.present?
			str += "\nPHONE: #{number_to_phone self.phone}"
		end
		if self.position.present?
			str += "\nPosition: #{self.position}"
		end
		if self.message.present?
			str += "\nMessage: #{self.message}"
		end
		str
	end

end
