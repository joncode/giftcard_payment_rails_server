class CreateBoomerang < ActiveRecord::Migration
  def change
    create_table :boomerangs do |t|
    end
  end
  drop_table :boomerang_givers

end
