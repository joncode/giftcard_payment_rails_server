class Social < ActiveRecord::Base

	has_many :proto_joins, as: :receivable
	has_many :protos, through: :proto_joins
    belongs_to  :payable,       polymorphic: :true, autosave: :true

end
