class UsersFullTextSearch < ActiveRecord::Migration
  def change
    add_column :users, :ftmeta, :tsvector

    reversible do |dir|
      dir.up do
        # Sets the ftmeta column with the tsvector data
        execute <<-SQL
          CREATE FUNCTION update_users_ftmeta() RETURNS trigger AS $$
          begin
            new.ftmeta :=
              setweight(to_tsvector(cast(new.id as text)), 'A') ||
              setweight(to_tsvector(concat(new.email)), 'B') ||
              setweight(to_tsvector(concat(new.first_name)), 'B') ||
              setweight(to_tsvector(concat(new.last_name)), 'B') ||
              setweight(to_tsvector(concat(new.address)), 'C') ||
              setweight(to_tsvector(concat(new.city)), 'C') ||
              setweight(to_tsvector(concat(new.state)), 'C') ||
              setweight(to_tsvector(concat(new.zip)), 'C') ||
              setweight(to_tsvector(concat(new.phone)), 'C') ||
              setweight(to_tsvector(concat(new.address_2)), 'D');
            return new;
          end
          $$ LANGUAGE plpgsql
        SQL

        # A trigger to update the ftmeta column on update/insert.
        execute <<-SQL
            CREATE TRIGGER update_users_ftmeta_trigger
                    BEFORE INSERT OR UPDATE
                        ON users
                  FOR EACH ROW
          EXECUTE PROCEDURE update_users_ftmeta()
        SQL

        # Touch each record so that the trigger creates our new metadata
        execute <<-SQL
          UPDATE users SET id=id;
        SQL

        execute <<-SQL
          CREATE INDEX users_ftsmeta_idx ON users USING gin(ftmeta)
        SQL

      end
      dir.down do
        execute <<-SQL
          DROP TRIGGER update_users_ftmeta_trigger ON users
        SQL

        execute <<-SQL
          DROP FUNCTION update_users_ftmeta()
        SQL
      end
    end
  end
end
