class Region < ActiveRecord::Base

	enum type_of: [ :city, :neighborhood ]

	has_many :providers
	has_many :merchants

	validates_presence_of :name

	before_create :make_token
	before_create :set_type_of

	default_scope -> { where(active: true) }  # indexed w/ city


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

