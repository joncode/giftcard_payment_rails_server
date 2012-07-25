class Connection < ActiveRecord::Base
  attr_accessible :giver_id, :receiver_id
end
