class ProtoJoin < ActiveRecord::Base

	belongs_to :receivable, polymorphic: true
	belongs_to :proto

	validates_uniqueness_of :gift_id, allow_nil: true

end
