class Oauth < ActiveRecord::Base
    belongs_to :gift

    validates_presence_of :gift_id, :network, :token
    validates :secret, presence: true, :if => :twitter?

private

    def twitter?
        self.network == "twitter"
    end
end
# == Schema Information
#
# Table name: oauths
#
#  id         :integer         not null, primary key
#  gift_id    :integer
#  token      :string(255)
#  secret     :string(255)
#  network    :string(255)
#  network_id :string(255)
#  handle     :string(255)
#  photo      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

