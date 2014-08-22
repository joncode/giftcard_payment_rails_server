require 'resque/plugins/resque_heroku_autoscaler'
require 'card_tokenizer'

class CardTokenizerJob
    #extend Resque::Plugins::HerokuAutoscaler

    @queue = :subscription

    def self.perform card_id
        puts "==== Starting CardTokenizerJob for Card #{card_id} ===="
		CardTokenizer.tokenize card_id
        puts "==== Ending Tokenizing Card #{card_id} ===="
    end

end