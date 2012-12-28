 class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.integer :user_id
      t.string  :nickname
      t.string  :name
      t.string  :number_digest
      t.string  :last_four
      t.string  :month
      t.string  :year
      t.string  :csv
      t.string  :type

      t.timestamps
    end
  end
end
