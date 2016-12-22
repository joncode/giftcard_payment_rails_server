workers Integer(ENV['PUMA_WORKERS'] || 5)
threads Integer(ENV['MIN_THREADS']  || 1), Integer(ENV['MAX_THREADS'] || 1)


rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || Rails.env
preload_app!

on_worker_boot do
  	# worker specific setup
	ActiveSupport.on_load(:active_record) do
		config = ActiveRecord::Base.configurations[Rails.env] || Rails.application.config.database_configuration[Rails.env]
		puts config.inspect
    	config['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10 # seconds
		# config['pool'] = ENV['MAX_THREADS'] || 16
    	config['pool'] =   ENV['DB_POOL'] || 2 #unicorn way
    	puts "puma.rb (17) Here is ActiveRecord::Base.establish_connection(config)"
    	puts ActiveRecord::Base.establish_connection(config)
	end

	ActiveSupport.on_load(:active_record) do
    	puts "puma.rb (22) Here is ActiveRecord::Base.establish_connection - no (config)"
    	puts ActiveRecord::Base.establish_connection
	end

	# If you are using Redis but not Resque, change this
	if defined?(Resque)
		Resque.redis = ENV['REDISTOGO_URL']
    	Rails.logger.info('Connected to Redis')
	end
end