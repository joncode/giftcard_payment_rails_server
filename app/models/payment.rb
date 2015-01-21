class Payment < ActiveRecord::Base

	belongs_to :partner,  polymorphic: true

	def affiliate
		self.partner
	end
end
