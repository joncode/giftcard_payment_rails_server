require 'resque/plugins/resque_heroku_autoscaler'
require 'card_tokenizer'

class CardTokenizerJob
    extend Resque::Plugins::HerokuAutoscaler

    @queue = :auth_net

    def self.perform card_id
        puts "==== Starting CardTokenizerJob for Card #{card_id} ===="
		CardTokenizer.tokenize card_id
        puts "==== Endig Tokenizing Card #{card_id} ===="
    end

end