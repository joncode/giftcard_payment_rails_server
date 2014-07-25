require 'resque/tasks'

task "resque:setup" => :environment do
	if Rails.env.production?
  		ENV['QUEUE'] = '*'
  	else
  		ENV['QUEUE'] = ['database', 'gifting', 'social', 'push', 'email', 'subscription', 'test','*']
  	end
end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"
