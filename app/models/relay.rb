class Relay < ActiveRecord::Base
	attr_accessible :gift_id, :giver_id, :name, :provider_id, :receiver_id, :status

	belongs_to :gift
	belongs_to :provider
	belongs_to :user , :as => :giver
	belongs_to :user , :as => :receiver

	validates_presence_of :gift_id, :provider_id, :status, :name 






end
