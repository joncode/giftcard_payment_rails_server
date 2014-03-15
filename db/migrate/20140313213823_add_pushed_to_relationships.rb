class AddPushedToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :pushed, :boolean, default: false
  end
end
