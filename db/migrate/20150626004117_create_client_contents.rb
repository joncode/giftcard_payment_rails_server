class CreateClientContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.integer :company_id
      t.string :company_type
      t.integer :client_id
      t.integer :content_id
      t.string :content_type

      t.timestamps
    end

    # add_index :contents, [:company_id, :company_type, :content_id, :content_type]
    add_index :contents, [:client_id, :content_id, :content_type]
    add_index :contents, [:company_id, :company_type, :content_type]
    add_index :contents, [:client_id, :content_type]

  end
end
