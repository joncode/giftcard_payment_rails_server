Dir[File.join(Rails.root, 'app', 'jobs', '*.rb')].each { |file| require file }

if Rails.env.production?
  uri = URI.parse(ENV["REDISTOGO_URL"])
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  Resque.redis = Redis.new(:host => "localhost", :port => 6379)
end

Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }