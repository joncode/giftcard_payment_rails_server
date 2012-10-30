class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :left
      t.string :right
    end
  end
end
