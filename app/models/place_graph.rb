class PlaceGraph < ActiveRecord::Base

	attr_accessor :parent, :place

	before_validation :set_parent

#   -------------

	validates_presence_of :place_id, :place_type, :parent_id, :parent_type
	validates :place_id, uniqueness: { scope: :parent_id }
	validates :place_id, uniqueness: { scope: :parent_type }, if: Proc.new { |a| a.parent.unique }

#   -------------

	# belongs_to :parent, foreign_key: :parent_id
	# belongs_to :child, foreign_key: :place_id

#   -------------

	def place
		@place ||= Place.find(self.place_id)
	end

	def parent
		@parent ||= Place.find(self.parent_id)
	end

	def parents
		PlaceGraph.where("place_id = #{self.place_id}").map(&:parent)
	end

	def places
		PlaceGraph.where("parent_id = #{self.place_id}").map(&:place)
	end

	def nodes
		PlaceGraph.where("place_id = #{self.place_id} OR parent_id = #{self.place_id}")
	end

#   -------------

	def set_parent
		unless self.parent
			self.parent = Place.find self.parent_id
		end
	end

	def self.add_node ch: , pa:
		return nil if (!ch.kind_of?(Place)) || (!pa.kind_of?(Place))
		nodes_created = []
		node = find_or_create_by place_id: ch.id, place_type: ch.type_of, parent_id: pa.id, parent_type: pa.type_of
		nodes_created << node
		other_nodes = where(place_id: pa.id)
		other_nodes.each do |pg|
			o_node = find_or_create_by place_id: ch.id, place_type: ch.type_of, parent_id: pg.parent_id, parent_type: pg.parent_type
			nodes_created << o_node
		end
		puts "PlaceGraph -add_node- #{nodes_created.inspect}"
		nodes_created
	end

end
