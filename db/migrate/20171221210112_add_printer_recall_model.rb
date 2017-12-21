class AddPrinterRecallModel < ActiveRecord::Migration
  def change
      create_table "printer_recalls", force: true do |t|
        t.string   :client_id
        t.string   :printer_name
        t.datetime :notified_at
        t.string   :type_of

        t.timestamps
      end
  end
end
