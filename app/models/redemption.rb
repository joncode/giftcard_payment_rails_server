class Redemption < ActiveRecord::Base

	enum type_of: [ :positronics ]

	belongs_to :gift

end
