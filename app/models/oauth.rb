class Oauth < ActiveRecord::Base

    validates_presence_of  :network, :token, :network_id
    validates :secret, presence: true, :if => :twitter?
    validates :handle, presence: true, :if => :twitter?

#   -------------

    belongs_to :gift
    belongs_to :user

#   -------------

    def net_id= network_id
        self.network_id = network_id
    end

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

    def self.create args={}
        oauth = self.where(gift_id: args["gift_id"], user_id: args["user_id"], network: args["network"], network_id: args["network_id"]).first
        if oauth.nil?
            super
        else
            oauth.update(token: args["token"], secret: args["secret"])
            oauth
        end
    end

#   -------------

    def to_proxy
        hsh = {}
        hsh["token"]        = self.token
        hsh["secret"]       = self.secret if self.secret
        hsh["network"]      = self.network
        hsh["network_id"]   = self.network_id
        hsh["handle"]       = self.handle if self.handle
        hsh
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
#  user_id    :integer
#

