class ProtoJoin < ActiveRecord::Base

	belongs_to :receivable, polymorphic: true
	belongs_to :proto

end
