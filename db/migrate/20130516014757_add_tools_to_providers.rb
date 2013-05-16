class AddToolsToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :tools, :boolean, :default => false
  end
end
