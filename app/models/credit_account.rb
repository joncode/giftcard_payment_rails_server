class CreditAccount < ActiveRecord::Base

  has_many :gifts, as: :payable

#   -------------

end
# == Schema Information
#
# Table name: credit_accounts
#
#  id         :integer         not null, primary key
#  owner      :string(255)
#  owner_id   :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

