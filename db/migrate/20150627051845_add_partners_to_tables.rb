class AddPartnersToTables < ActiveRecord::Migration
  def change
  	add_column :users, :partner_id, :integer
  	add_column :users, :partner_type, :string
  	add_column :users, :client_id, :integer
  	add_column :cards, :partner_id, :integer
  	add_column :cards, :partner_type, :string
  	add_column :cards, :origin, :string
  	add_column :cards, :client_id, :integer
  	add_column :gifts, :partner_id, :integer
  	add_column :gifts, :partner_type, :string
  	add_column :gifts, :client_id, :integer
  	add_column :gifts, :rec_client_id, :integer
  	add_column :session_tokens, :origin, :string
  	add_column :session_tokens, :partner_id, :integer
  	add_column :session_tokens, :partner_type, :string
  	add_column :session_tokens, :client_id, :integer
  	add_column :session_tokens, :destroyed_at, :datetime
  	add_column :session_tokens, :count, :integer, default: 0
  end
end