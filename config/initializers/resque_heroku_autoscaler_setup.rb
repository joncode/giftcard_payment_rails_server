require 'resque/plugins/resque_heroku_autoscaler'

# turn off scaling workers in development or test
if Rails.env.development? || Rails.env.test?
  Resque::Plugins::HerokuAutoscaler.config do |c|
    c.scaling_allowed = false
  end
end