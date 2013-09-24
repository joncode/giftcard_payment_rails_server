class AddLiveAndPausedToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :live, :boolean, default: false
    add_column :providers, :paused, :boolean, default: true
  end
end
