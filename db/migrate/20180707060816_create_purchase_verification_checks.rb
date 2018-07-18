class CreatePurchaseVerificationChecks < ActiveRecord::Migration
  def change
    create_table :purchase_verification_checks do |t|
      t.string    :hex_id
      t.integer   :verification_id  # Link to parent
      t.string    :session_id       # Shared with parent for easy lookups
      t.datetime  :expires_at       # Expiration of this check
      t.datetime  :verified_at      # Used for pass lookups
      t.datetime  :failed_at        # Used for fail lookups; Timestamp of e.g. a failed SMS check
      t.string    :check_type       # Specific check type, such as sms, ideology, etc.  (`type` is a magic Rails keyword)
      t.string    :rule_name        # Speed up reverifications; also used for reporting.
      t.json      :rule_options     # For fraud analysis
      t.string    :frequency        # Store the source frequency for the check, such as: once, transaction, always
      t.json      :data             # stores extra data for the check, e.g. sms code
      t.json      :request          # request sent to the client
      t.json      :response         # response received from the client
      t.timestamps
    end

    add_index :purchase_verification_checks, :hex_id
  end
end
