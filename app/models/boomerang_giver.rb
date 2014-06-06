class BoomerangGiver < ActiveRecord::Base
	include Formatter

    has_many :sent,  as: :giver,  class_name: Gift

	def name
		"Boomerang"
	end

	def get_photo
		"http://res.cloudinary.com/drinkboard/image/upload/v1389818563/IOM-icon_round_bzokjj.png"
	end

	def short_image_url
		shorten_photo_url self.get_photo
	end

end