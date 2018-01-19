class FixTypoInEpsonPrintersColumn < ActiveRecord::Migration
  def change
    rename_column :epson_printers, :last_polll_capture_at, :last_poll_capture_at
  end
end
