class CardFraudDetectionJob

    @queue = :after_save

    def self.perform card_id
        puts "==== Starting CardFraudDetectionJob for Card #{card_id} ===="
		card = Card.unscoped.find(card_id)

			## same number different account alert
		num = card.number_digest
		cs = Card.unscoped.where(number_digest: num)
		if cs.length > 1
			return Alert.perform("CARD_FRAUD_DETECTED_SYS", card.user)
		end

			##  double upload alert
		cs = Card.where(user_id: card.user_id).where('created_at > ?', 15.minutes.ago)
		if cs.count > 1
			return Alert.perform("CARD_FRAUD_DETECTED_SYS", card.user)
		end

			##  triple upload alert
		cs = Card.where(user_id: card.user_id).where('created_at > ?', 1.hour.ago)
		if cs.count > 2
			return Alert.perform("CARD_FRAUD_DETECTED_SYS", card.user)
		end
    end

end
