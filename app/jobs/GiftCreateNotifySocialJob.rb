#require 'resque/plugins/resque_heroku_autoscaler'

class GiftCreateNotifySocial
    #extend Resque::Plugins::HerokuAutoscaler

    @queue = :push

    def self.perform gift_id
        puts " -------------   Notify Social Create Gift Via Facebook  --------------------"
        if gift = Gift.find(gift_id)
            FacebookOperations.notify_gift(gift)
        end
    end

end