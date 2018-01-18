class AddColumnActiveToEpsonPrinters < ActiveRecord::Migration
  def change
    add_column :epson_printers, :active, :boolean, default: true
  end
end
