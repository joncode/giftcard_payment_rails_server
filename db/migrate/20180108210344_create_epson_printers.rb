class CreateEpsonPrinters < ActiveRecord::Migration
  def change
    create_table :epson_printers do |t|
        t.string    :ip
        t.string    :name
        t.string    :client_id
        t.string    :application_key           # duplicate data, but removes the need for a lookup if the printer doesn't always provide this.
        t.string    :recall_id
        t.boolean   :tracking                  # `nil` allows automatically enabling tracking
        t.datetime  :last_polll_capture_at     # "capture" because we don't update this every time
        t.datetime  :last_status_at
        t.datetime  :last_mechanical_error_at  # Store the timestamp of the last error (storing each error would add up quickly and wouldn't tell us much)
        t.datetime  :last_cutter_error_at      # likewise
        t.datetime  :cover_open_at             # (Duration): Store the first timestamp; reset to `nil` when resolved
        t.datetime  :paper_low_at              # (Duration)
        t.datetime  :paper_out_at              # (Duration)

        t.timestamps
    end
  end
end
