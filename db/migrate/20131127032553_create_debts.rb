class CreateDebts < ActiveRecord::Migration
  def change
    create_table :debts do |t|
      t.references :owner, polymorphic: true
      t.decimal    :amount, :precision => 8, :scale => 2
      t.decimal    :total, :precision => 8, :scale => 2
      t.string     :detail
      t.timestamps
    end
  end
end
