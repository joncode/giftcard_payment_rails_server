class Place < ActiveRecord::Base

#   -------------

	before_validation :set_unique

#   -------------

	validates_presence_of :abbr, :name, :type_of
	# validates :abbr, uniqueness: { scope: :type_of }, if: Proc.new { |a| a.unique }

#   -------------

	# has_many :place_graphs, as: :parent
	# has_many :place_graphs, as: :place
	# has_many :parents, through: place_graphs, foreign_key: parent_id

#   -------------

	def set_unique
		self.unique = !['zip', 'neighborhood', 'metroarea'].include?(type_of)
		return true
	end

	def unique?
		self.unique
	end

#   -------------

	def get pa: nil, ch: nil, abbr: nil
		if pa
			sql = "SELECT p.* FROM places p, place_graphs g
WHERE g.place_id = #{self.id} AND g.parent_type = '#{pa}'
AND p.id = g.parent_id"
			sql += " AND p.abbr = '#{abbr}'" if abbr
			ary = Place.connection.execute(sql)
		else
			sql = "SELECT p.* FROM places p, place_graphs g
WHERE g.parent_id = #{self.id} AND g.place_type = '#{ch}'
AND p.id = g.place_id"
			sql += " AND p.abbr = '#{abbr}'" if abbr
			ary = Place.connection.execute(sql)
		end
		ary.map { |a| Place.new a }
	end

	def self.usa
		Place.where(type_of: 'country', abbr: 'US').first
	end

	def self.can
		Place.where(type_of: 'country', abbr: 'CA').first
	end

	def self.gb
		Place.where(type_of: 'country', abbr: 'GB').first
	end

#   -------------

	def parents
		sql = "SELECT p.* FROM places p, place_graphs g
 WHERE g.place_id = #{self.id} AND p.id = g.parent_id "
		ary = Place.connection.execute(sql)
		ary.map { |a| Place.new a }
	end

	def places
		sql = "SELECT p.* FROM places p, place_graphs g
WHERE g.parent_id = #{self.id} AND p.id = g.place_id "
		ary = Place.connection.execute(sql)
		ary.map { |a| Place.new a }
	end

	def nodes
		sql = "SELECT p.* FROM places p, place_graphs g
WHERE (g.parent_id = #{self.id} AND p.id = g.place_id) OR (g.place_id = #{self.id} AND p.id = g.parent_id)"
		ary = Place.connection.execute(sql)
		ary.map { |a| Place.new a }
	end
end




# obj.id = 1 => Place.new(abbr: 'EARTH', name: 'Earth', detail: 'our planet', photo: <url>, active: true, type_of: 'planet', unique: true)
# obj.id = 2 => Place.new(abbr: 'NA', name: 'North America', detail: 'north american continent', photo: <url>, active: true, type_of: 'continent', unique: true)
# obj.id = 3 => Place.new(abbr: 'US', name: 'United States of America', detail: 'United States of America', photo: <url>, active: true, type_of: 'country', unique: true)
# obj.id = 3 => Place.new(abbr: 'US', name: 'Canada', detail: 'Canada', photo: <url>, active: true, type_of: 'country', unique: true)
# obj.id = 4 => Place.new(abbr: 'NV', name: 'Nevada', detail: '', photo: <url>, active: true, type_of: 'state', unique: true)
# obj.id = 5 => Place.new(abbr: 'LV', name: 'Las Vegas', detail: '', photo: <url>, active: true, type_of: 'city', unique: true)
# obj.id = 6 => Place.new(abbr: 'DTLV', name: 'Downtown', detail: '', photo: <url>, active: true, type_of: 'neighborhood', unique: false)
# obj.id = 7 => Place.new(abbr: 'CC', name: 'Clark County', detail: 'Southernmost county in Nevada', photo: <url>, active: true, type_of: 'county', unique: true)
# obj.id = 8 => Place.new(abbr: 'CVLND', name: 'Cleveland Metro Area', detail: 'The greater cleveland area', photo: <url>, active: true, type_of: 'metroarea', unique: false)
# obj.id = 9 => Place.new(abbr: '89101', name: '89101', detail: 'Las Vegas Zipcode', photo: <url>, active: true, type_of: 'zip', unique: false)