class CreateMicroposts < ActiveRecord::Migration
  def change
    create_table :microposts do |t|
      t.string  :content, null: false
      t.integer :user_id, null: false
      t.integer :video_id

      t.timestamps
    end
  end
end
