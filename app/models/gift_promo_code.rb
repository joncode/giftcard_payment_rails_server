class GiftPromoCode

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
            if gifts.empty?
                return { status: 0, data: fail_msg }
            else
                good = 0
                scheduled = 0
                gifts.each do |g|
                    if g.persisted?
                        good += 1
                        scheduled += 1 if ( g.status == 'schedule' )
                    else
                        fail_gift = g
                    end
                end
                if good > 0
                    if scheduled == 0
                        success_msg = "Your gift has been delivered.\nKeyword '#{str_code}'"
                    elsif scheduled == good
                        success_msg = "#{scheduled} #{'gift'.pluralize(scheduled)} scheduled for later delivery.\nKeyword '#{str_code}'"
                    else
                        delivery_now = good - scheduled
                        success_msg = "Your gift has been delivered.\n"
                        success_msg += "#{scheduled} #{'gift'.pluralize(scheduled)} scheduled for later delivery.\nKeyword '#{str_code}'"
                    end
                    # success(success_msg)
                    return { status: 1, data: success_msg }
                else
                    # fail fail_gift
                    return { status: 0, data: fail_gift }
                end
            end
        end
	end

end