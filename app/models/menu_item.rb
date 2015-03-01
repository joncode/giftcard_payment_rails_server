class MenuItem < ActiveRecord::Base

end
# == Schema Information
#
# Table name: menu_items
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  section_id  :integer
#  menu_id     :integer
#  detail      :text
#  price       :string(255)
#  photo       :string(255)
#  position    :integer
#  active      :boolean         default(TRUE)
#  price_promo :string(255)
#  standard    :boolean         default(FALSE)
#  promo       :boolean         default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#

