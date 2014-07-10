class Contact < ActiveRecord::Base

	has_many :proto_joins, as: :receivable
	has_many :protos, through: :proto_joins

end
