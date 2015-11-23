class MerchantsFullTextSearch < ActiveRecord::Migration
  def change
    add_column :merchants, :ftmeta, :tsvector


    reversible do |dir|
      dir.up do
        # Sets the ftmeta column with the tsvector data
        execute <<-SQL
          CREATE FUNCTION update_merchants_ftmeta() RETURNS trigger AS $$
          begin
            new.ftmeta :=
              setweight(to_tsvector(cast(new.id as text)), 'A') ||
              setweight(to_tsvector(concat(new.name)), 'B') ||
              setweight(to_tsvector(concat(new.phone)), 'B') ||
              setweight(to_tsvector(concat(new.email)), 'B') ||
              setweight(to_tsvector(concat(new.address)), 'C') ||
              setweight(to_tsvector(concat(new.city_name)), 'C') ||
              setweight(to_tsvector(concat(new.state)), 'C') ||
              setweight(to_tsvector(concat(new.zip)), 'C');
            return new;
          end
          $$ LANGUAGE plpgsql
        SQL

        # A trigger to update the ftmeta column on update/insert.
        execute <<-SQL
            CREATE TRIGGER update_merchants_ftmeta_trigger
                    BEFORE INSERT OR UPDATE
                        ON merchants
                  FOR EACH ROW
          EXECUTE PROCEDURE update_merchants_ftmeta()
        SQL

        # Touch each record so that the trigger creates our new metadata
        execute <<-SQL
          UPDATE merchants SET id=id;
        SQL

        execute <<-SQL
          CREATE INDEX merchants_ftsmeta_idx ON merchants USING gin(ftmeta)
        SQL

      end
      dir.down do
        execute <<-SQL
          DROP TRIGGER update_merchants_ftmeta_trigger ON merchants
        SQL

        execute <<-SQL
          DROP FUNCTION update_merchants_ftmeta()
        SQL
      end
    end
  end
end
