# == Schema Information
#
# Table name: cards
#
#  id            :integer         not null, primary key
#  user_id       :integer
#  nickname      :string(255)
#  name          :string(255)
#  number_digest :string(255)
#  last_four     :string(255)
#  month         :string(255)
#  year          :string(255)
#  csv           :string(255)
#  brand         :string(255)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

require 'test_helper'

class CardTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
