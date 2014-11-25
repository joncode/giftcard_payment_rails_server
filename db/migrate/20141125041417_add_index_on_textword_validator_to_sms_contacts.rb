class AddIndexOnTextwordValidatorToSmsContacts < ActiveRecord::Migration
  def change
  	  	add_index :sms_contacts, [:textword, :phone, :campaign_id]
  end
end
