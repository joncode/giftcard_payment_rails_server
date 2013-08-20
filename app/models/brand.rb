class Brand < ActiveRecord::Base
	attr_accessible :address, :city, :description,
	:logo, :name, :phone, :state, :user_id, :website,
	:photo, :portrait, :next_view

	# attr_accessible :crop_x, :crop_y, :crop_w, :crop_h
 #  	attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

	has_many   :providers
	has_many   :employees
	belongs_to :user

	validates_presence_of :name

    default_scope where(active: false)

    after_save :update_parent_brand

  	# mount_uploader :photo, BrandPhotoUploader

    def self.get_all
        unscoped.order("name ASC")
    end

  	def serialize
  		brand_hash 	= self.serializable_hash only: [ :name, :next_view ]
        brand_hash["brand_id"] = self.id
        brand_hash["photo"]    = self.get_image
  		brand_hash
  	end

    def admt_serialize
        brand_hash  = self.serializable_hash only: [ :name, :description, :website ]
        brand_hash["brand_id"] = self.id
        brand_hash["photo"]    = self.get_image
        brand_hash["active"]   = self.active ? 1 : 0
        brand_hash
    end

  	def next_view
  		super || "m"
  	end

  	def has_photo?
  		!self.photo.nil?
  	end

	def get_image
		self.photo
	end

    def photo= photo_url
        # remove the cloudinray base url
        new_url = photo_url.split(CLOUDINARY_IMAGE_URL)[1]
        # save the shortened URL in db
        super new_url
    end

    def photo
        short_url = super
        if short_url
            CLOUDINARY_IMAGE_URL + short_url
        else
            nil
        end
    end

	def get_photo_for_web
		unless image = self.photo
			image = MERCHANT_DEFAULT_IMG
		end
		return image
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
#

