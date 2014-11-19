class CreateDataTransfers < ActiveRecord::Migration
  def change
    create_table :data_transfers do |t|
    	t.json :model_names
    	t.json :data
    	t.timestamps
    end
  end
end
