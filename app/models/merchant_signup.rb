class MerchantSignup < ActiveRecord::Base
	include ActionView::Helpers::NumberHelper


#   -------------


	validates_presence_of  :venue_name, :point_of_sale_system, :name
	# validates :email , format: { with: VALID_EMAIL_REGEX }, allow_blank: true
	# validates :phone , format: { with: VALID_PHONE_REGEX }, allow_blank: true
	validates_length_of :name,      :maximum => 100
	validates_length_of :position,  :maximum => 100
	validates_length_of :venue_name,:maximum => 100
	validates_length_of :venue_url, :maximum => 100, allow_blank: true
	validates_length_of :address, 	:maximum => 500, allow_blank: true
	validates_length_of :message,   :maximum => 500
	validates_length_of :point_of_sale_system,  :maximum => 100

#   -------------

	after_commit :notify_internal, on: :create

#   -------------

	has_many :clients, as: :partner

	belongs_to :merchant

#   -------------

	def self.get_clover_signup pos_merchant_id
		return nil if pos_merchant_id.to_s.blank?
		return nil unless pos_merchant_id.to_s.length > 5
		find_by(pos_merchant_id: pos_merchant_id, active: true)
	end

	def self.new_clover args
		args.delete(:app_key)
		m = new
		m.data = args
		m.message = "Clover Machine Initialized - Signup Requested"
		m.position = 'CloverPOS'
		m.point_of_sale_system = 'clover'
		m.venue_name = args[:name].titleize if args[:name].kind_of?(String)
		m.name = m.venue_name
		m.email = args[:email].gsub(',','').gsub('typecom.clover.account','').downcase if args[:email].kind_of?(String)
		m.phone = args[:phone].gsub(/[^0-9]/,'') if args[:phone].kind_of?(String)
		m.address = args[:address1].titleize if args[:address1].kind_of?(String)
		m.website = args[:website]
		m.venue_url = args[:website]
		m.device_id = args[:device_id]
		m.pos_merchant_id = args[:pos_merchant_id]
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

#   -------------

	def notify_internal
		Resque.enqueue(InternalMailerJob, { 'method' => 'mail_notice_submit_merchant_setup', 'args' => self })
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

