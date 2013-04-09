class Menu < ActiveRecord::Base
    attr_accessible :item_id, :position, :price, :provider_id, 
    :item_name, :photo, :description, :section, :active


    belongs_to   :provider
    belongs_to   :item
    has_many     :gift_items

    validates_presence_of :item_name, :price, :provider_id, :section
    validates_numericality_of :price
    before_save :satisfy_item_id_null_constraint
    after_save :update_provider

    def satisfy_item_id_null_constraint
      if self.item_id.nil?
        self.item_id = 0
      end
    end

    def update_provider
      self.provider.update_attribute(:menu_is_live, false)
    end

    def self.where(params)
        if params.kind_of?(Hash) && !params.has_key?(:active) && !params.has_key?("active")
          params[:active] = true
        end
        super(params)
    end

    def self.get_sections(provider_id)
        menu_items = Menu.where(provider_id: provider_id)
        # sections = {"special" => "", "beer" => "", "wine" => "", "cocktail"=> "", "shot" => ""}
        sections = {}
        menu_items.each do |mi|
          if !mi.section
            category = BEVERAGE_CATEGORIES[mi.item.category]
            sections[category] = ""
          else
            sections[mi.section] = ""
          end
        end

        sections_array = []
        BEVERAGE_CATEGORIES.each do |cat|
          if sections.has_key? cat
            sections_array << cat
          end
        end
        return sections_array
    end

    def self.get_menu_in_section(provider_id, section_name)
        # category = BEVERAGE_CATEGORIES.index(section_name)
        menu_items = Menu.where(provider_id: provider_id)
        menu_section = []
        menu_items.each do |menu|
            # the old way 
          # if menu.item.category == category
          #   menu_display = menu.display_object
          #   menu_section << menu_display
          # end
            # the new way
          if menu.section == section_name
            menu_display = menu.display_object
            menu_section << menu_display
          end
        end

        return menu_section
    end

    def self.get_full_menu_array(provider_id,sections_array=nil)
        full_menu_array = []

          # generate section array from menu items
        if !sections_array
          sections_array = Menu.get_sections(provider_id)
        end

        sections_array.each do |section_name|      
          # array_of_menu_section = Menu.where(provider_id: provider_id, header: category).order("position ASC")
          array_of_menu_section = Menu.get_menu_in_section(provider_id, section_name)
          if #array_of_menu_section.count > 0
            section_hash = { section_name => array_of_menu_section }
            full_menu_array << section_hash
          else
              # do not build menu for this section heading
          end
        end
        return full_menu_array
    end

    def self.get_menu_array_for_builder(provider)
        menu        = self.get_full_menu_array(provider.id,BEVERAGE_CATEGORIES)
        menu_array  = []
        menu.each do |mi|
          menu_array << mi.flatten
        end
        return menu_array
    end

    def display_object
        changed = false
        if item = self.item


          # item name
          if self.item_name.nil?
            self.item_name = item.item_name
            changed = true
          end

          # photo_url - choose menu photo above item photo
          if self.photo.nil?
            self.photo = item.photo
            changed = true
          end

          # item description
          if self.description.nil?
            self.description = item.description
            changed = true
          end

          # item section
          if self.section.nil?
            self.section = BEVERAGE_CATEGORIES[item.category]
            changed = true
          end
        end
        self.save if changed
        menu_item_obj = self.serializable_hash only: [:id, :item_name, :price, :photo, :section, :description]
        menu_item_obj["menu_item_id"] = self.id
        return menu_item_obj
    end


  
end
# == Schema Information
#
# Table name: menus
#
#  id          :integer         not null, primary key
#  provider_id :integer         not null
#  item_id     :integer         not null
#  price       :string(20)
#  position    :integer(8)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  item_name   :string(255)
#  photo       :string(255)
#  description :string(255)
#  section     :string(255)
#

