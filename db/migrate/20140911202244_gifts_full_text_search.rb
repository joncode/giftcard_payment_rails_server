class GiftsFullTextSearch < ActiveRecord::Migration
  def change
    add_column :gifts, :ftmeta, :tsvector

    reversible do |dir|
      dir.up do
        # Sets the ftmeta column with the tsvector data
        execute <<-SQL
          CREATE FUNCTION update_gifts_ftmeta() RETURNS trigger AS $$
          begin
            new.ftmeta :=
              setweight(to_tsvector(cast(new.id as text)), 'A') ||
              setweight(to_tsvector(concat(new.order_num)), 'B') ||
              setweight(to_tsvector(concat(new.receiver_email)), 'B') ||
              setweight(to_tsvector(concat(new.receiver_name)), 'B') ||
              setweight(to_tsvector(concat(new.provider_name)), 'C') ||
              setweight(to_tsvector(concat(new.giver_name)), 'C') ||
              setweight(to_tsvector(concat(new.status)), 'D');
            return new;
          end
          $$ LANGUAGE plpgsql
        SQL

        # A trigger to update the ftmeta column on update/insert.
        execute <<-SQL
            CREATE TRIGGER update_gifts_ftmeta_trigger
                    BEFORE INSERT OR UPDATE
                        ON gifts
                  FOR EACH ROW
          EXECUTE PROCEDURE update_gifts_ftmeta()
        SQL

        # Touch each record so that the trigger creates our new metadata
        execute <<-SQL
          UPDATE gifts SET id=id;
        SQL

        execute <<-SQL
          CREATE INDEX gifts_ftsmeta_idx ON gifts USING gin(ftmeta)
        SQL

      end
      dir.down do
        execute <<-SQL
          DROP TRIGGER update_gifts_ftmeta_trigger ON gifts
        SQL

        execute <<-SQL
          DROP FUNCTION update_gifts_ftmeta()
        SQL
      end
    end
  end
end
