class Register < ActiveRecord::Base
	enum origin:  [ :iom, :loc, :aff_user, :aff_loc ]
	enum type_of: [ :debt, :credit ]

	belongs_to :partner,  polymorphic: true

	def affiliate
		self.partner
	end

end
