class AddTenderTypeIdToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :tender_type_id, :string
    add_column :merchants, :tender_type_id, :string
  end
end
