class BoomerangPushJob
    extend UrbanAirshipWrap

    @queue = :push

    def self.perform gift_id
        gift        = Gift.find gift_id

        receiver = gift.giver
        return nil unless receiver.respond_to?(:ua_alias)
        # badge       = Gift.get_notifications(receiver)
        # payload     = self.format_payload(gift, receiver, badge)

        alert = "Boomerang! We are returning this gift to you because your friend never created an account"
        puts "SENDING BoomerangPushJob NOTE for GIFT ID = #{gift_id} | #{alert}"
        self.send_push(receiver, alert, gift_id)
        return true

    end

private

    def self.format_payload(gift, receiver, badge)
        {
            :aliases => [receiver.ua_alias],
            :aps => {
                :alert => "Boomerang! We are returning this gift to you because your friend never created an account",
                :badge => badge,
                :sound => 'pn.wav'
            },
            :alert_type => 1,
            :android => {
                :alert => "Boomerang! We are returning this gift to you because your friend never created an account",
            }
        }
    end
end
