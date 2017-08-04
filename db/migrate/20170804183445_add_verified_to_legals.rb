class AddVerifiedToLegals < ActiveRecord::Migration
  def change
    add_column :legals, :verified, :boolean, default: false
  end
end
