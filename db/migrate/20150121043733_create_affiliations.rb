class CreateAffiliations < ActiveRecord::Migration
  def change
    create_table :affiliations do |t|
      t.integer :affiliate_id
      t.integer :target_id
      t.string  :target_type
      t.string  :name
      t.string  :address
      t.integer :payout, default: 0
      t.integer :status, default: 0

      t.timestamps
    end
    add_index :affiliations, [:affiliate_id, :target_type]
    add_index :affiliations, :affiliate_id
  end
end
