class GiftPromoCode
    include ActionView::Helpers::DateHelper

	def self.perform user, str_code
		return { status: 0, data: 'User Missing' } unless user.kind_of?(User)
		return { status: 0, data: 'Code Missing' } unless (str_code.kind_of?(String) && !str_code.blank?)
		str_code = str_code.strip.downcase
        protos = Proto.where(active: true, promo_code: [ str_code, str_code.gsub(/\s+/, "") ])
        fail_msg = "couldn't find item for keyword #{str_code}"
        if protos.empty?
            return { status: 0, data: fail_msg }
        else
            gifts = []
            protos.each do |proto|
                if proto.gifting?
                    pj = ProtoJoin.create_with_proto_and_rec(proto, user)
                    if pj.persisted?
                        gift = GiftProtoJoin.create({ "proto_join" => pj, "proto" => proto})
                        gifts << gift
                    else
                        if (fail_msg != "we're sorry but this promo has reached capacity and is no longer live")
                            if pj.errors.messages.values.join(' ').match(/has already been take/)
                                fail_msg = "You have already received this promotion for keyword #{str_code}"
                            else
                                fail_msg = pj.errors.full_messages.gsub('Proto', 'Promo Gift')
                            end
                        end
                    end
                else
                    fail_msg = proto.gifting_fail_msg
                end
            end
            return { status: 0, data: fail_msg }  if gifts.empty?

            good      = 0
            scheduled = 0
            failed    = []

            gifts.each do |gift|
                if gift.persisted?
                    good += 1
                    scheduled += 1  if gift.status == 'schedule'
                else
                    failed << gift
                end
            end

            return { status: 0, data: failed }  if good.zero?


            later = ""
            if scheduled > 0
                earliest_gift = gifts.order(scheduled_at: :desc).first
                days = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]  # Note: for use with wday, NOT cwday

                # Friendly future date for the earliest gift
                later = if earliest_gift.scheduled_at.today?
                            # Ex: later today (about 5 hours from now)
                            "later today (#{time_ago_in_words(earliest_gift.scheduled_at)} from now)"
                        elsif (earliest_gift.scheduled_at - 1.day).today?
                            # Ex: tomorrow (the 12th)
                            "tomorrow (the #{earliest_gift.scheduled_at.day.ordinalize})"
                        elsif (earliest_gift.scheduled_at - 2.days).today?
                            # Ex: the day after tomorrow (on the 13th)
                            "the day after tomorrow (on the #{earliest_gift.scheduled_at.day.ordinalize})"
                        elsif earliest_gift.scheduled_at < (DateTime.now.sunday - 1.day)
                            # Weeks end at midnight on Saturday
                            # Ex: "this week, on Tuesday the 8th"
                            "this week on #{days[earliest_gift.scheduled_at.wday]} the #{earliest_gift.scheduled_at.day.ordinalize}"
                        elsif earliest_gift.scheduled_at < (DateTime.now.sunday + 1.week - 1.day)
                            # Ex: "this week, on Tuesday the 8th"
                            "next week on #{days[earliest_gift.scheduled_at.wday]} the #{earliest_gift.scheduled_at.day.ordinalize}"
                        else
                            # Too far out for relative dates? Just format it nicely.
                            # Ex: "on Sunday the 17th of June, 2020"
                            later = strftime("on %A the #{earliest_gift.scheduled_at.day.ordinalize} of %B, %Y")
                        end
            end

            delivered = good - scheduled

            # Summarize result for the user
            success_msg  = []
            success_msg << 'Your gift has been delivered.'                        if delivered == 1
            success_msg << "Your #{good - scheduled} gifts have been delivered!"  if delivered  > 1

            if scheduled > 0
                line  = 'You '
                line += 'also '  if delivered > 0
                line += 'have '
                line += (scheduled == 1 ? "a gift " : "#{scheduled} gifts ")
                line += 'scheduled for delivery'
                line += ', with the earliest arriving'  if (scheduled) > 1
                line += " #{later}."

                success_msg << line
            end

            return { status: 1, data: success_msg.join("\n") }
        end
	end

end