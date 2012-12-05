# == Schema Information
#
# Table name: sales
#
#  id              :integer         not null, primary key
#  gift_id         :integer
#  giver_id        :integer
#  card_id         :integer
#  request_string  :string(255)
#  response_string :string(255)
#  status          :string(255)
#  provider_id     :integer
#  transaction_id  :string(255)
#  revenue         :decimal(, )
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

require 'test_helper'

class SaleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
