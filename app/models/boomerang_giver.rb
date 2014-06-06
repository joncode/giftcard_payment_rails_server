class BoomerangGiver < ActiveRecord::Base
	include Formatter

    has_many :gifts,  as: :giver,  class_name: Gift

	def name
		"Boomerang"
	end

	def get_photo
		"http://res.cloudinary.com/drinkboard/image/upload/v1389818563/IOM-icon_round_bzokjj.png"
	end

	def short_image_url
		shorten_photo_url self.get_photo
	end

	def message
        "Your friend never created an account so we’re returning this gift. Use Regift to try your friend again, send it to a new friend, use the gift yourself!"
    end

    def self.giver
    	BoomerangGiver.first
    end

end