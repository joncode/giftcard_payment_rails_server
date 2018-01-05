class AddDetailsToPrinterRecall < ActiveRecord::Migration
  def change
    add_column :printer_recalls, :details, :string
  end
end
