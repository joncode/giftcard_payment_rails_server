class CreateLicenses < ActiveRecord::Migration
  def change
    create_table :licenses, id: :uuid do |t|
      t.string :status
      t.string :partner_type
      t.integer :partner_id
      t.date :live_at
      t.date :expires_at
      t.string :origin
      t.string :name
      t.string :detail
      t.string :detail_action
      t.string :amount_action
      t.integer :amount
      t.integer :percent
      t.integer :units
      t.string :ccy
      t.string :recurring_type
      t.string :weekday
      t.integer :process_month
      t.integer :process_day
      t.integer :notify_day
      t.string :charge_type
      t.integer :charge_id
      t.text :note

      t.timestamps null: false
    end

    add_index :licenses, :status
    add_index :licenses, [:partner_type, :partner_id]
  end
end

# id: '9234fg23-23yf9g3-2hg3f71',
# status: 'live',
# partner_id: 31,
# partner_type: 'Affiliate',
# live_date: '2/01/2016',
# end_date: '2/01/2017',
# auto_renew: false,
# origin: 'subscription',
# name: 'Subscription Fee',
# detail: '100 golf courses - tier 2',
# detail_action: nil,
# amount: 2500000,
# percent: nil,
# amount_action: 'multiple',
# units: 100,
# ccy: "USD",
# recurring_type: 'annual',
# weekday: nil,
# process_month: 2,
# process_day: 1,
# notify_day: nil,
# charge_type: 'check',
# charge_id: nil
