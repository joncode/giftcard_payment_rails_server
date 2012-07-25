class Provider < ActiveRecord::Base
  attr_accessible :address, :city, :description, :logo, :name, :state, :user_id, :zip
end
