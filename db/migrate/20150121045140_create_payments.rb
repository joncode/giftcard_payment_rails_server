class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :auth_date
      t.string  :conf_num
      t.integer :m_transactions
      t.integer :m_amount
      t.integer :u_transactions
      t.integer :u_amount
      t.integer :total
      t.boolean :paid
      t.integer :partner_id
      t.string  :partner_type

      t.timestamps
    end
    add_index :payments, [:partner_id, :partner_type]
  end
end
