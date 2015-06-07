class Region < ActiveRecord::Base

	enum type_of: [ :city, :neighborhood ]

	has_many :providers
	has_many :merchants

	validates_presence_of :name

	before_create :make_token
	before_create :set_type_of

	default_scope -> { where(active: true) }  # indexed w/ city

	def self.all_for_clients
		cities = Region.city.order(id: :asc).where(active: true)
		neighborhoods = Region.neighborhood.where(active: true)
		new_ary = []

		cities.each do |city|
			new_ary << city
			new_ary.concat(get_neighborhoods_for_city(city, neighborhoods))
		end
		new_ary
	end

	def self.get_neighborhoods_for_city city, array_of_regions
		puts city.inspect
		puts array_of_regions.inspect
		array_of_regions.select do |region|
			region.neighborhood? && region.city_id == city.id
		end
	end

	def as_json(*args)
	    super.tap do |hash|
	    	hash.delete('city_id')
	    	hash.delete('state_id')
	    	hash.delete('created_at')
	    	hash.delete('updated_at')
	    	hash.delete('active')
	    	hash["region_id"] = hash.delete 'id'
	    end
	end

	def old_city_json
		hsh = {}
		hsh['name'] = self.name
		hsh['state'] = self.detail
		hsh['photo'] = self.photo
		hsh['region_id'] = self.id
		hsh['city_id'] = self.id
		hsh['token'] = self.token
		hsh
	end



private

	def make_token
		self.token = self.name.downcase.gsub(' ', '-')
	end

	def set_type_of
		self.type_of = :neighborhood if self.city_id.present?
	end

end

# == Schema Information
#
# Table name: regions
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  detail     :string(255)
#  state_id   :integer
#  city_id    :integer
#  photo      :string(255)
#  banner     :string(255)
#  active     :boolean
#  type_of    :integer         default(0)
#  token      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

