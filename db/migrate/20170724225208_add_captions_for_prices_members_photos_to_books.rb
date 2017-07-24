class AddCaptionsForPricesMembersPhotosToBooks < ActiveRecord::Migration
  	def change
		add_column :books, :photo1, :string
		add_column :books, :photo1_name, :string
		add_column :books, :photo2, :string
		add_column :books, :photo2_name, :string
		add_column :books, :photo3, :string
		add_column :books, :photo3_name, :string
		add_column :books, :photo4, :string
		add_column :books, :photo4_name, :string
		add_column :books, :member1, :string
		add_column :books, :member1_name, :string
		add_column :books, :member2, :string
		add_column :books, :member2_name, :string
		add_column :books, :member3, :string
		add_column :books, :member3_name, :string
		add_column :books, :member4, :string
		add_column :books, :member4_name, :string
		add_column :books, :price1, :integer
		add_column :books, :price1_name, :string#, default: "Price per person with Wine"
		add_column :books, :price2, :integer
		add_column :books, :price2_name, :string#, default: "Price per person w/o Wine"
  	end

  	def move_legacy_data
  		Book.all.each do |b|
  			b.price1 = b.price
  			b.price1_name = "Price per person w/o Wine"
  			if b.price_wine
	  			b.price2 = b.price_wine
	  			b.price2_name = "Price per person with Wine"
  			end
  			b.members.each_with_index do | ary, i|
  				k = ary[0]
  				v = ary[1]
  				if k
  					token = 'member' + (i + 1).to_s
  					title_t = ( token + '=' ).to_sym
  					name_t = ( token + '_name' + '=' ).to_sym
  					b.send(title_t, k)
  					b.send(name_t, v)
  				end
  			end
  			b.photos.each_with_index do | ary, i|
  				k = ary[0]
  				v = ary[1]
  				if v
  					b.update_column(k, v)
  				end
  			end
	  		b.save
  		end
  		nil
  	end



end



