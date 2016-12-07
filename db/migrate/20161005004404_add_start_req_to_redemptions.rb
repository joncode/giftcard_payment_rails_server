class AddStartReqToRedemptions < ActiveRecord::Migration
  def change
  	add_column :redemptions, :start_req, :json
  	add_column :redemptions, :start_res, :json
  	add_column :redemptions, :request_at, :datetime
  	add_column :redemptions, :response_at, :datetime
  end
end
