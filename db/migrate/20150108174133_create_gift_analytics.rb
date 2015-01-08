class CreateGiftAnalytics < ActiveRecord::Migration
  	def change
    	create_table :gift_analytics do |t|
    		  t.date       :date_on
      		t.integer    :created, default: 0
      		t.integer    :admin, default: 0
      		t.integer    :merchant, default: 0
      		t.integer    :campaign, default: 0
      		t.integer    :purchase, default: 0
      		t.integer    :boomerang, default: 0
      		t.integer    :other, default: 0
      		t.integer    :regifted, default: 0
      		t.integer    :notified, default: 0
      		t.integer    :redeemed, default: 0
      		t.integer    :expired, default: 0
      		t.integer    :cregifted, default: 0
      		t.integer    :completed, default: 0
      		t.integer    :velocity, default: 0
      		t.integer    :revenue, default: 0
      		t.integer    :profit, default: 0
      		t.integer    :retail_v, default: 0
      		t.timestamps
    	end
      add_index :gift_analytics, :date_on
    end

end
