class AddMenuIsLiveToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :menu_is_live, :boolean, default: false
  end
end
