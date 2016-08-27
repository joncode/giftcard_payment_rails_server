class CreateLegals < ActiveRecord::Migration
  def change
    create_table :legals do |t|
      t.string :first_name
      t.string :last_name
      t.string :business_tax_id
      t.string :personal_id
      t.string :entity_type, default: 'company'
      t.string :date_of_birth
      t.integer :company_id
      t.string :company_type

      t.timestamps null: false
    end
  end
end
