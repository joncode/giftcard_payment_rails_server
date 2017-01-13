class MerchantSignup < ActiveRecord::Base
	include ActionView::Helpers::NumberHelper


#   -------------


	validates_presence_of  :venue_name, :point_of_sale_system, :name, :email
	validates :email , format: { with: VALID_EMAIL_REGEX }, allow_blank: true
	validates :phone , format: { with: VALID_PHONE_REGEX }, allow_blank: true
	validates_length_of :name,      :maximum => 100
	validates_length_of :position,  :maximum => 100
	validates_length_of :venue_name,:maximum => 100
	validates_length_of :venue_url, :maximum => 100, allow_blank: true
	validates_length_of :address, 	:maximum => 500, allow_blank: true
	validates_length_of :message,   :maximum => 500
	validates_length_of :point_of_sale_system,  :maximum => 100


#   -------------

	has_many :clients, as: :partner

#   -------------

	def self.get_clover_signup mid
		return nil if mid.to_s.blank?
		return nil unless mid.to_s.length > 5
		find_by(message: mid)
	end

	def self.new_clover args
		m = new
		m.venue_name = args[:name]
		m.email = args[:email]
		m.message = args[:mid]
		m.position = 'CloverPOS'
		m.point_of_sale_system = 'clover'
		m.name = args[:mid]
		m.website = args[:device_id]
		m
	end


#   -------------


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

    def destroy
            # DO NOT DELETE RECORDS
        update_column(:active, false)
    end

end
# == Schema Information
#
# Table name: merchant_signups
#
#  id                   :integer         not null, primary key
#  name                 :string(255)
#  position             :string(255)
#  email                :string(255)
#  phone                :string(255)
#  website              :string(255)
#  venue_name           :string(255)
#  venue_url            :string(255)
#  point_of_sale_system :string(255)
#  message              :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  active               :boolean         default(TRUE)
#  address              :string(255)
#

