class AddDeviseToMtUsers < ActiveRecord::Migration
  def self.up
    change_table(:mt_users) do |t|
      ## Database authenticatable
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at


      # Uncomment below if timestamps were not included in your original model.
      # t.timestamps
    end

    add_index :mt_users, :reset_password_token, unique: true
    # add_index :mt_users, :confirmation_token,   unique: true
    # add_index :mt_users, :unlock_token,         unique: true
  end

  def self.down
    remove_column :mt_users, :encrypted_password
    remove_column :mt_users, :reset_password_sent_at
    remove_column :mt_users, :remember_created_at
    remove_column :mt_users, :sign_in_count
    remove_column :mt_users, :current_sign_in_at
    remove_column :mt_users, :last_sign_in_at
    remove_column :mt_users, :current_sign_in_ip
    remove_column :mt_users, :last_sign_in_ip
  end
end

