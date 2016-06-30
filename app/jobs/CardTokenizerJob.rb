#require 'resque/plugins/resque_heroku_autoscaler'
require 'card_tokenizer'

class CardTokenizerJob
    #extend Resque::Plugins::HerokuAutoscaler

    @queue = :after_save

    def self.perform card_id
        puts "==== Starting CardTokenizerJob for Card #{card_id} ===="
		card = Card.unscoped.find(card_id)
		if card.active
			card.tokenize
		end
        puts "==== Ending Tokenizing Card #{card_id} ===="
    end

end


