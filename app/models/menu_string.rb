class MenuString < ActiveRecord::Base

  	belongs_to :provider

  	validates_uniqueness_of :provider_id
    validates_presence_of   :menu
    validates_with JsonArrayValidator

  	after_save :update_merchant

    def self.get_menu_v2_for_provider provider_id
        menu_string = MenuString.find_by(provider_id: provider_id)
        if menu_string
            if menu_string.menu
                return menu_string.menu
            elsif  menu_string.data
                # generate menu_string.menu lazy
                menu_json        = menu_string.create_new_menu_string menu_string.data
                menu_string.menu = menu_json
                menu_string.save
                return menu_json
            else
                # source the menu from merchant tools
                nil
            end
        else
            # provider id is incorrect
            nil
        end
    end

    def create_new_menu_string old_menu
        old_menu = JSON.parse(old_menu) if old_menu.kind_of?(String)
        old_menu.map do |s|
            { "section" => s.keys[0] , "items" => s[s.keys[0]] }
        end.to_json
    end

#########    DEPRECATED - these will not work with menu now sourced on merchant tools

   	def self.get_menu_for_provider(provider_id)

  		menu_string = MenuString.find_by(provider_id: provider_id)
  		if !menu_string
			menu_string      = MenuString.new
			menu_string_data = menu_string.generate_new_menu_string(provider_id)
		elsif menu_string.version == 1
  			menu_string_data = menu_string.generate_menu_string(provider_id)

		else
			menu_string_data = menu_string.data
		end
		return menu_string_data
  	end

    def self.compile_menu_to_menu_string(provider_id)
        menu_string = MenuString.find_by(provider_id: provider_id)
        if !menu_string
            menu_string = MenuString.new
            menu_string_data = menu_string.generate_new_menu_string(provider_id)
        else
            menu_string_data = menu_string.generate_menu_string(provider_id)
        end

        return true
    end

################

private

    def update_merchant
        unless self.menu.nil?
            if provider = Provider.unscoped.find(self.provider_id)
                if not provider.menu_is_live
                    provider.update_attribute(:menu_is_live, true)
                end
            end
        end
    end

####### DEPRECATED - these will not work with menu now sourced on merchant tools

			# remake menu string from menu
	def generate_new_menu_string(provider_id)
		self.full_address 	= Provider.find(provider_id).complete_address
		self.provider_id 	= provider_id
		return self.generate_menu_string(provider_id)
	end

	def generate_menu_string(provider_id)
		menu_string_data = Menu.get_full_menu_array(provider_id).to_json
        puts "IN GENERATE MENU STRING - SHOULD NEVER BE HERE !!!"
		self.data           = menu_string_data
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

###############

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
#  menu          :text
#

