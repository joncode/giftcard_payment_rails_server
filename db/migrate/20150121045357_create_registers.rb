class CreateRegisters < ActiveRecord::Migration
  def change
    create_table :registers do |t|
      t.integer :gift_id
      t.integer :amount
      t.integer :partner_id
      t.string :partner_type
      t.integer :origin, default: 0
      t.integer :type_of, default: 0

      t.timestamps
    end
    add_index :registers, [:created_at, :partner_id, :partner_type]
    add_index :registers, [:gift_id, :origin]
  end
end
