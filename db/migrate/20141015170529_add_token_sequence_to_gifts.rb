class AddTokenSequenceToGifts < ActiveRecord::Migration
	def change

		add_column :gifts, :token, :integer

	    reversible do |dir|
	      dir.up do
	        execute <<-SQL
				CREATE SEQUENCE gift_token_seq MINVALUE 1000 MAXVALUE 9999 CACHE 100 CYCLE;
	        SQL

	      end
	      dir.down do
	        execute <<-SQL
	          DROP SEQUENCE gift_token_seq;
	        SQL
	      end
	    end
	end
end
