require 'authorize_net'

module CardTokenizeAll

	def self.tokenize_all
		cards = Card.where(cim_token: nil)
		cards.count
		puts "============== Starting Group Tokenization - Untokenized Cards: #{cards.count} =============="
		cards.each do |card|
			card.tokenize
		end
		cards_after = Card.where(cim_token: nil).count
		puts "============== Ending Group Tokenization - Untokenized Cards: #{cards_after_count} =============="
	end

end
