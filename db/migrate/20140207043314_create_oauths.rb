class CreateOauths < ActiveRecord::Migration
  def change
    create_table :oauths do |t|
      t.integer  :gift_id
      t.string   :token
      t.string   :secret
      t.string   :network
      t.string   :network_id
      t.string   :handle
      t.string   :photo
      t.timestamps
    end
  end
end
