class CreatePnTokens < ActiveRecord::Migration
  def change
    create_table :pn_tokens do |t|
      t.integer  :user_id
      t.string   :pn_token
    end

    add_index :pn_tokens, :user_id
  end
end
