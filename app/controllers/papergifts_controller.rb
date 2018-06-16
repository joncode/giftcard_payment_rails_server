class PapergiftsController < ApplicationController

    def paper_cert
        puts "PAPER GIFT REQUEST #{params.inspect}"
        @gift = Gift.includes(:merchant).find_with(params[:id])
        if @gift.kind_of?(Gift) && ['incomplete', 'open', 'notified', 'schedule'].include?(@gift.status)
            resp = Redeem.start(gift: @gift, api: "/papergifts/#{params[:id]}", type_of: :paper)
            # puts resp.inspect
            if resp['success']
                @redemption = resp['redemption']
                @gift = resp['gift']

                @items = @gift.cart.collect do |item|
                    "#{item['quantity']}x #{item['item_name']}"
                end

                if @items.count > 3
                    _count = @items.count
                    @items = @items[0..1]
                    @items << "(And #{_count} more)"
                end

                @value_dollars, @value_cents = @gift.value.split(".")
                @value_cents ||= "00"

                respond_to do |format|
                    format.html
                    format.pdf do
                        render pdf: "paper_gifts", encoding: :utf8
                    end
                end
            else
                render :text => resp['response_text']
            end
        else
            raise ActiveRecord::RecordNotFound
        end
    end

end
