class Menu < ActiveRecord::Base
    has_many    :menu_items , through: :sections
    has_many    :sections, 	dependent: :destroy
    has_many  :merchants



end