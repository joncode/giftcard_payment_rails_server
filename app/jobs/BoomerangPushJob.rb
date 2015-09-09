class BoomerangPushJob
    extend UrbanAirshipWrap

    @queue = :push

    def self.perform gift_id
        gift        = Gift.find gift_id

        receiver    = gift.receiver
        badge       = Gift.get_notifications(receiver)
        payload     = self.format_payload(gift, receiver, badge)

        puts "SENDING BoomerangPushJob NOTE for GIFT ID = #{gift_id} | #{payload}"
        self.ua_push(payload, gift_id)

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
