class AddNewDefaultsAndPhotosToBooks < ActiveRecord::Migration
	def change
		change_column_default :books, :tip_rate, 0.20
		change_column_default :books, :advance_days, 3
		change_column_default :books, :min_ppl, 1
		change_column_default :books, :max_ppl, 20

		add_column :books, :photo_banner, :string
		add_column :books, :photo_banner_name, :string
		add_column :books, :photo_logo, :string
		add_column :books, :photo_logo_name, :string
		add_photos_to_banner_and_logo
	end

	def add_photos_to_banner_and_logo
		Book.all.each do |book|
			book.photo_banner = book.photo1
			book.photo_banner_name = book.photo1_name
			book.photo_logo = book.photo1
			book.photo_logo_name = book.photo1_name
			book.save
		end
	end

end
