class ChangeNullSqlConstraintPasswordDigestOnUser < ActiveRecord::Migration
  def up
  	change_column_null(:users, :password_digest, nil)
  end

  def down
  end
end
