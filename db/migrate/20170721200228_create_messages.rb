class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :status, default: 'live'
      t.string :message
      t.boolean :active, default: true
      t.integer :company_id
      t.string :company_type

      t.timestamps null: false
    end
  end
end
