class AppContact < ActiveRecord::Base
    include ModelValidationHelper

    has_many :friendships, dependent: :destroy
    has_many :users, through: :friendships

    before_validation { |social| social.network_id = strip_and_downcase(network_id)   if is_email? }
    before_validation { |social| social.network_id = extract_phone_digits(network_id) if is_phone? }

    validates :network, presence: true
    validates :network_id, presence: true
    validates_with UniqueNetworkValidator


end

  # create_table "app_contacts", force: true do |t|
  #   t.integer  "user_id"
  #   t.string   "network"
  #   t.string   "network_id"
  #   t.string   "name"
  #   t.date     "birthday"
  #   t.string   "handle"
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  # end
