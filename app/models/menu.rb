class Menu < ActiveRecord::Base
  attr_accessible :item_id, :position, :price, :provider_id, 
  :item_name, :photo, :description, :section


  belongs_to   :provider
  belongs_to   :item
  has_many     :gift_items
  has_and_belongs_to_many :gifts

  def self.get_sections(provider_id)
    menu_items = Menu.where(provider_id: provider_id)
    sections = {}
    menu_items.each do |mi|
      category = BEVERAGE_CATEGORIES[mi.item.category]
      sections[category] = ""
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
    category = BEVERAGE_CATEGORIES.index(section_name)
    menu_items = Menu.where(provider_id: provider_id)
    menu_section = []
    menu_items.each do |menu|
      if menu.item.category == category
        menu_display = menu.display_object
        menu_section << menu_display
      end
    end

    return menu_section
  end

  def self.get_full_menu_array(provider_id)
    full_menu_array = []

      # generate section array from menu items
    sections_array = Menu.get_sections(provider_id)

    sections_array.each do |section_name|      
      # array_of_menu_section = Menu.where(provider_id: provider_id, header: category).order("position ASC")
      array_of_menu_section = Menu.get_menu_in_section(provider_id, section_name)
      if array_of_menu_section.count > 0
        section_hash = { section_name => array_of_menu_section }
        full_menu_array << section_hash
      else
          # do not build menu for this section heading
      end
    end
    return full_menu_array
  end

  def self.get_menu_array_for_builder(provider)
    menu        = self.get_full_menu_array provider.id
    menu_array  = []
    menu.each do |mi|
      menu_array << mi.flatten
    end
    return menu_array
  end

  def display_object
   item = self.item

   changed = false
  
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

