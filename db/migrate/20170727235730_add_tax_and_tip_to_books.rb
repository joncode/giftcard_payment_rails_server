class AddTaxAndTipToBooks < ActiveRecord::Migration
  def change
    add_column :books, :tax_tip_included, :boolean, default: true
    add_column :books, :tax_rate, :decimal, default: 0.0
    add_column :books, :tax_name, :string, default: "Tax"
    add_column :books, :tip_rate, :decimal, default: 0.18
    add_column :books, :tip_name, :string, default: "Gratuity"
  end
end
