# == Schema Information
#
# Table name: brands
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :string(255)
#  address     :string(255)
#  city        :string(255)
#  state       :string(255)
#  phone       :string(255)
#  website     :string(255)
#  logo        :string(255)
#  photo       :string(255)
#  portrait    :string(255)
#  user_id     :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  owner_id    :integer
#  next_view   :string(255)
#  child       :boolean         default(FALSE)
#

require 'test_helper'

class BrandTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
