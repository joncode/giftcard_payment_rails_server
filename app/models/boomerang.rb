class Boomerang < ActiveRecord::Base
	include Formatter

    has_many :gifts,  as: :giver,  class_name: Gift

	def name
		"Boomerang"
	end

	def get_photo
		"http://res.cloudinary.com/drinkboard/image/upload/v1402519573/boomerang_120x120_clshuw.png"
	end

	def short_image_url
		shorten_photo_url get_photo
	end

	def message
        "Your friend never created an account so we’re returning this gift. Use Regift to try your friend again, send it to a new friend, use the gift yourself!"
    end

    def self.giver
    	Boomerang.first
    end

end