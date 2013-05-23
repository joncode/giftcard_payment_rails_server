class MenuString < ActiveRecord::Base
  	attr_accessible :full_address, :data, :provider_id, :version, :sections_json, :menu

  	belongs_to :provider

  	validates_uniqueness_of :provider_id

  	after_save :update_merchant

  	def update_merchant
  		self.provider.update_attribute(:menu_is_live, true)
  	end

   	def self.get_menu_for_provider(provider_id)
  		menu_string = MenuString.find_by_provider_id(provider_id)
  		if !menu_string
			menu_string = MenuString.new
			menu_string_data = menu_string.generate_new_menu_string(provider_id)
		elsif menu_string.version == 1
  			menu_string_data = menu_string.generate_menu_string(provider_id)

		else
			menu_string_data = menu_string.data
		end
		return menu_string_data
  	end

			# remake menu string from menu
	def generate_new_menu_string(provider_id)
		self.full_address 	= Provider.find(provider_id).complete_address
		self.provider_id 	= provider_id
		return self.generate_menu_string(provider_id)
	end

	def generate_menu_string(provider_id)
		menu_string_data = Menu.get_full_menu_array(provider_id).to_json

		self.data = menu_string_data
		puts "IN GENERATE MENU STRING"
		self.version 		= 2
		sections_array 		= Menu.get_sections(provider_id)
		self.sections_json 	= sections_array.to_json
		self.provider_id 	= provider_id if !self.provider_id

		if self.save
			puts "MENU STRING FOR #{provider_id} SAVED"
		else
			puts "FAILED !! MENU STRING FOR #{provider_id} FAILED !! "
		end
		return menu_string_data
	end

	def self.compile_menu_to_menu_string(provider_id)
		menu_string = MenuString.find_by_provider_id(provider_id)
		if !menu_string
			menu_string = MenuString.new
			menu_string_data = menu_string.generate_new_menu_string(provider_id)
		else
  			menu_string_data = menu_string.generate_menu_string(provider_id)
  		end

		return true
	end
end

















# == Schema Information
#
# Table name: menu_strings
#
#  id            :integer         not null, primary key
#  version       :integer
#  provider_id   :integer         not null
#  full_address  :string(255)
#  data          :text            not null
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  sections_json :string(255)
#

