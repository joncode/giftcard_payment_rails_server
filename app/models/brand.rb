class Brand < ActiveRecord::Base

	default_scope -> { where(active: true) }  # indexed

#   -------------

	validates :name, presence: true, :uniqueness => { case_sensitive: false }

#   -------------

	after_save :update_parent_brand

#   -------------

	has_many   :providers
	belongs_to :user

#   -------------

	def self.get_all
		unscoped.order("name ASC")
	end

#   -------------

	def serialize
		brand_hash  = self.serializable_hash only: [ :name, :next_view ]
		brand_hash["brand_id"] = self.id
		brand_hash["photo"]    = self.get_photo
		brand_hash
	end

	def admt_serialize
		brand_hash  = self.serializable_hash only: [ :name, :description, :website ]
		brand_hash["brand_id"] = self.id
		brand_hash["photo"]    = self.get_photo
		brand_hash["active"]   = self.active ? 1 : 0
		brand_hash
	end

#   -------------

	def next_view
		super || "m"
	end

	def has_photo?
		!self.photo.nil?
	end

	def get_photo
		if self.photo.present?
			CLOUDINARY_IMAGE_URL + self.photo
		elsif self.portrait.present?
			CLOUDINARY_IMAGE2_URL + self.portrait
		else
			nil
		end
	end

	def photo= photo_url
		# remove the cloudinary base url
		if photo_url
			new_url = photo_url.split(CLOUDINARY_IMAGE_URL)[1]
		else
			new_url = nil
		end
		super new_url
	end

	def providers
		merchants = Provider.where("brand_id = ? OR building_id = ?", self.id, self.id)
		if self.child
			# getting the merchants connected to child brands
			children = self.brands
			children.each do |child|
				child_merchants = Provider.where("brand_id = ? OR building_id = ?", child.id, child.id)
				merchants.concat child_merchants
			end
		end
		return merchants
	end

	def brands
		Brand.where(owner_id: self.id)
	end

	def owner
		Brand.find owner_id if owner_id
	end

	def city_state_zip
		"#{self.description}"
	end

private

	def update_parent_brand
		if self.owner_id
			owner_brand = Brand.find(self.owner_id)
			owner_brand.update_attribute(:child, true) unless owner_brand.child
			puts "Updated owner brand = #{owner_brand.id}"
		end
	end

end
# == Schema Information
#
# Table name: brands
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :string(255)
#  address     :string(255)
#  city        :string(255)
#  state       :string(255)
#  phone       :string(255)
#  website     :string(255)
#  logo        :string(255)
#  photo       :string(255)
#  portrait    :string(255)
#  user_id     :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  owner_id    :integer
#  next_view   :string(255)
#  child       :boolean         default(FALSE)
#  active      :boolean         default(TRUE)
#

