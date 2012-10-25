# == Schema Information
#
# Table name: menu_strings
#
#  id           :integer         not null, primary key
#  version      :integer
#  provider_id  :integer         not null
#  full_address :string(255)
#  data         :text            not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

class MenuString < ActiveRecord::Base
  attr_accessible :full_address, :data, :provider_id, :version, :sections_json
  
  belongs_to :provider
  
  def self.get_menu_for_provider(provider_id)
  	menu_string = MenuString.find_by_provider_id(provider_id) 
  	if (!menu_string) || (menu_string.version == 1)
  		menu_string = generate_menu_string(provider_id, menu_string)
	end
	return menu_string	
  end

  private
  			# remake menu string from menu
  	def generate_menu_string(provider_id, menu_string)
		full_menu_array = []
		
			# generate section array from menu items
		sections_array = Menu.get_sections(provider_id)

		sections_array.each do |section_name|
			
			# array_of_menu_section = Menu.where(provider_id: provider_id, header: category).order("position ASC")
			array_of_menu_section = Menu.get_menu_section(provider_id, section_name)
			if array_of_menu_section.count > 0
				section_hash = { section_name => array_of_menu_section }
				full_menu_array << section_hash 
			else
			    # do not build menu for this section heading
			end
		end
		menu_string_data = full_menu_array.to_json 

  		menu_string.data = menu_string_data
  		menu_string.version = 2
  		menu_string.sections_json = sections_array.to_json
  		menu_string.provider_id = provider_id if !menu_string.provider_id
  		
  		menu_string.save

  		return menu_string_data
  	end
end

















