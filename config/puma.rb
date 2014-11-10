workers Integer(ENV['PUMA_WORKERS'] || 3)
threads Integer(ENV['MIN_THREADS']  || 1), Integer(ENV['MAX_THREADS'] || 4)


rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || Rails.env
preload_app!

on_worker_boot do
  	# worker specific setup
	ActiveSupport.on_load(:active_record) do
		config = ActiveRecord::Base.configurations[Rails.env] || Rails.application.config.database_configuration[Rails.env]
    	config['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10 # seconds
		config['pool'] = ENV['MAX_THREADS'] || 16
    	#config['pool']            =   ENV['DB_POOL'] || 2 #unicorn way
    	ActiveRecord::Base.establish_connection(config)
	end

	ActiveSupport.on_load(:active_record) do
		ActiveRecord::Base.establish_connection
	end


	# If you are using Redis but not Resque, change this
	if defined?(Resque)
		Resque.redis = ENV['REDISTOGO_URL']
    	Rails.logger.info('Connected to Redis')
	end
end