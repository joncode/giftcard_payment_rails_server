class CreateProtoJoins < ActiveRecord::Migration
  def change
    create_table :proto_joins do |t|
      t.integer    :proto_id
      t.references :receivable, polymorphic: true
      t.timestamps
    end

    add_index :proto_joins, [:receivable_id, :receivable_type]
  end
end
