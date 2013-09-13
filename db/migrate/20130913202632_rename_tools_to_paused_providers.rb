class RenameToolsToPausedProviders < ActiveRecord::Migration
  def up
    rename_column :providers, :tools, :paused
  end

  def down
    rename_column :providers, :paused, :tools
  end
end
