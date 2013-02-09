class CreateSubtleData < ActiveRecord::Migration
  def change
    create_table :subtle_data do |t|

      t.timestamps
    end
  end
end
