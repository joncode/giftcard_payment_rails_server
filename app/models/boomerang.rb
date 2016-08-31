class Boomerang < ActiveRecord::Base
	include ShortenPhotoUrlHelper

#   -------------

    has_many :gifts,  as: :giver,  class_name: Gift

#   -------------

    def self.giver
    	Boomerang.first
    end

#   -------------

	def first_name
		"ItsOnMe Return to Sender"
	end

	def name
		"Boomerang"
	end

	def get_photo
		"http://res.cloudinary.com/drinkboard/image/upload/v1402519573/boomerang_120x120_clshuw.png"
	end

	def short_image_url
		shorten_photo_url get_photo
	end


end

# == Schema Information
#
# Table name: boomerangs
#
#  id :integer         not null, primary key
#

