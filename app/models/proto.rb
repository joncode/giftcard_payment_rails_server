class Proto < ActiveRecord::Base

	belongs_to :receivable, polymorphic: true
	has_many   :proto_joins
	has_many   :users, 		through: :proto_joins, source: :receivable, source_type: 'User'
	has_many   :socials, 	through: :proto_joins, source: :receivable, source_type: 'Social'
	#has_many   :receivables, through: :proto_joins, source: :receivable, source_type: "Receivable"

	def receivables
		self.users + self.socials
	end

end
