namespace :import do
  desc "Sanitize the production data dump"
  task :sanitize_data => :environment do
    unless Rails.env.to_sym == :development 
      raise "This is only to be run in a development environment"
    end

    puts "Sanitizing the production data import"
    #count = User.update_all(:email => ["no-reply+?@itson.me", ])
    sql = <<-SQL 
      UPDATE users SET 
        email = 'no-reply+' || id || '_' || first_name || '_' || last_name || '@itson.me'
       ,credit_number = ''
       ,password_digest = ''
       ,reset_token = ''
       ,remember_token = ''
    SQL
    count = ActiveRecord::Base.connection.execute(sql)
    puts "records modified: #{count.cmd_status}"
  end
end
