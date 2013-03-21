class RemoveReplayMessageAndSpecialInstructionsFromRedeems < ActiveRecord::Migration
  def up
  	remove_column :redeems, :reply_message
  	remove_column :redeems, :special_instructions
  end

  def down
  	add_column :redeems, :reply_message, :string
  	add_column :redeems, :special_instructions, :text
  end
end
