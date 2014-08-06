class Social < ActiveRecord::Base
	include ModelValidationHelper

	has_many :proto_joins, as: :receivable
	has_many :protos, through: :proto_joins
	has_many :at_users_socials
	has_many :at_users, through: :at_users_socials

    belongs_to  :payable,       polymorphic: :true, autosave: :true

    before_validation { |social| social.network_id = strip_and_downcase(network_id)   if is_email? }
	before_validation { |social| social.network_id = extract_phone_digits(network_id) if is_phone? }

	validates_presence_of :network, :network_id
    validates :network_id , format: { with: VALID_PHONE_REGEX }, :if => :is_phone?
    validates :network_id , format: { with: VALID_EMAIL_REGEX }, :if => :is_email?

    validates :network_id, :uniqueness => { scope: :network }

end
