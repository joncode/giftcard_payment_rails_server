class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name
      t.string :url_name
      t.string :download_url
      t.string :application_key
      t.string :detail
      t.integer :partner_id
      t.string :partner_type
      t.integer :platform, default: 0
      t.boolean :active, default: true
      t.integer :ecosystem, default: 0

      t.timestamps
    end
    add_index :clients, [:application_key, :active]
  end

end
