class ListGraph < ActiveRecord::Base

	default_scope -> { order(position: :asc) }

#   -------------

	validates_presence_of :list_id, :item_id, :item_type

#   -------------

	belongs_to :item, foreign_key: :item_id, foreign_type: :item_type, polymorphic: true
	belongs_to :list

#   -------------


end
