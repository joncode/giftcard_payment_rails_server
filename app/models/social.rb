class Social < ActiveRecord::Base
	include JsonHelper

	has_many :proto_joins, as: :receivable
	has_many :protos, through: :proto_joins
    belongs_to  :payable,       polymorphic: :true, autosave: :true

    before_validation :strip_and_downcase, :if => :is_email?
	before_validation { |social| social.network_id = extract_phone_digits(network_id) if network == 'phone' }

	validates_presence_of :network, :network_id
    validates :network_id , format: { with: VALID_PHONE_REGEX }, :if => :is_phone?
    validates :network_id , format: { with: VALID_EMAIL_REGEX }, :if => :is_email?

    validates :network_id, :uniqueness => { scope: :network }

private

	def is_email?
    	self.network == "email"
	end

	def is_phone?
    	self.network == "phone"
	end

    def strip_and_downcase
        if self.network_id.kind_of?(String)
            self.network_id = self.network_id.downcase.strip
        end
    end


end
