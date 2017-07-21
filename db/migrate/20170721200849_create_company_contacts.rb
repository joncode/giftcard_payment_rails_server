class CreateCompanyContacts < ActiveRecord::Migration
  def change
    create_table :company_contacts do |t|
      t.string :company_type
      t.integer :company_id
      t.string :type
      t.integer :contact_id
      t.string :status, default: 'live'
      t.boolean :active, default: true

      t.timestamps null: false
    end
  end
end
