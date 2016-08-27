class Legal < ActiveRecord::Base

#   -------------

	validates_presence_of :business_tax_id, :company_id, :company_type
	validates_presence_of :date_of_birth, :first_name, :last_name, :personal_id, if: :non_us?
	validates_uniqueness_of :company_id, scope: :company_type

#   -------------

	before_save { |legal| legal.first_name = first_name.titleize }
	before_save { |legal| legal.last_name  = NameCase(last_name) }

#   -------------

	belongs_to :company, polymorphic: true

#   -------------





private

	def non_us?
		self.company.ccy != 'USD'
	end


end