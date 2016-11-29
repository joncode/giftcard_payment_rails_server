Dir[File.join(Rails.root, 'app', 'jobs', '*.rb')].each { |file| require file }

if Rails.env.production?
	ENV["REDISTOGO_URL"] ||= "redis://redistogo:973cdc884e18482f5b324194e3b4cde1@barb.redistogo.com:9497/"
	uri = URI.parse(ENV["REDISTOGO_URL"])
	host = uri.host
	port = uri.port
	password = uri.password
	Resque.redis = Redis.new(:host => host, :port => port, :password => password)
elsif Rails.env.staging?
	ENV["REDISTOGO_URL"] ||= "redis://redistogo:7a26911511c6ef1c1b2f32fad240ae0a@squawfish.redistogo.com:9819/"
	uri = URI.parse(ENV["REDISTOGO_URL"])
	host = uri.host
	port = uri.port
	password = uri.password
	Resque.redis = Redis.new(:host => host, :port => port, :password => password)
else
	host = "localhost"
	port = 6379
	password = nil
	Resque.redis = Redis.new(:host => host, :port => port, :password => password)
end


Resque.after_fork do
	puts "Resque after_fork"
	puts ActiveRecord::Base.establish_connection

  	Resque.redis = Redis.new(:host => host, :port => port, :password => password)
end

