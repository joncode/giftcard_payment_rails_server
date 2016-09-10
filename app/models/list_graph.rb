class ListGraph < ActiveRecord::Base

	default_scope -> { order(position: :asc) }

#   -------------

	validates_presence_of :item_id, :item_type
	validates_uniqueness_of :list_id, scope: [:item_id, :item_type]

#   -------------

	before_save :set_position

#   -------------

	belongs_to :list
	belongs_to :item, foreign_key: :item_id, foreign_type: :item_type, polymorphic: true

#   -------------

private

	def set_position
		if self.position.nil?
			last_lg = ListGraph.unscoped.where(list_id: self.list_id).order(position: :desc).first
			if last_lg
				self.position = last_lg.position + 1
			else
				self.position = 0
			end
		end
	end

end
