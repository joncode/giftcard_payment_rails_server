class CreateDailyStats < ActiveRecord::Migration
  def change
    create_table :daily_stats do |t|
      t.string :dash_day_old
      t.string :dash_week_old
      t.string :dash_month_old
      t.string :dash_total
      t.timestamps
    end
  end
end
