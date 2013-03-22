class Brand < ActiveRecord::Base
	attr_accessible :address, :city, :description, 
	:logo, :name, :phone, :state, :user_id, :website, 
	:photo, :portrait

	attr_accessible :crop_x, :crop_y, :crop_w, :crop_h 
  	attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

	has_many :providers
	has_many :employees
	belongs_to :user

  	mount_uploader :photo,    BrandPhotoUploader

  	def has_photo?
  		!self.photo.file.nil?
  	end

	def get_image
		self.photo.url
	end

	def get_photo_for_web
		unless image = self.photo.url
			image = "#{CLOUDINARY_IMAGE_URL}/v1349150293/upqygknnlerbevz4jpnw.png"
		end
		return image
	end

	def providers
		Provider.where("brand_id = ? OR building_id = ?", self.id, self.id)
	end

	def city_state_zip
	    "#{self.description}"
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
#  photo      :string(255)
#  portrait    :string(255)
#  user_id     :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

