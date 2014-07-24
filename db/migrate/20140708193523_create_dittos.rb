class CreateDittos < ActiveRecord::Migration
  def change
    create_table :dittos do |t|
      t.text 		   :response_json
      t.integer 	 :status
      t.integer 	 :cat
      t.references 	:notable, polymorphic: true
      t.timestamps
    end

    add_index :dittos, [:notable_id, :notable_type]
  end
end
