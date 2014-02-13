class Oauth < ActiveRecord::Base
    belongs_to :gift

    validates_presence_of :gift_id, :network, :token
    validates :secret, presence: true, :if => :twitter?

    def self.initFromDictionary hsh
        oauth = Oauth.new
        oauth.token      = hsh["token"]
        oauth.secret     = hsh["secret"]
        oauth.network    = hsh["network"]
        oauth.network_id = hsh["network_id"]
        oauth.handle     = hsh["handle"]
        oauth.photo      = hsh["photo"]
        oauth
    end

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

