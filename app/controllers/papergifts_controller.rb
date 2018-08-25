class PapergiftsController < ApplicationController

    before_action :resolve_gift, only: [:paper_cert]

    # GET  /papergifts/:rd/balance
    def balance
        puts "\n\n[controller Papergifts :: balance]"
        puts " | rd: #{params[:rd]}"

        err = nil
        err = "Invalid gift id"  unless params[:rd].downcase.starts_with? "rd"

        redemption = Redemption.where_with(params[:rd]).first
        err = "Unable to find gift"  if redemption.nil?

        if err.present?
            render json: {status: 0, err: "INVALID INPUT", msg: err} and return
        end

        gift  = redemption.gift
        paper = REDEMPTION_HSH.values.map(&:downcase).index("paper")  # Because id=>string, and it's capitalized!
        last_redemption = gift.redemptions.where.not(type_of: paper)
                                          .where(status: "pending")
                                          .order(created_at: :desc).last

        json = {}
        json[:hex_id]            = params[:rd]
        json[:original_value]    = gift.original_value / 100.0
        json[:balance]           = gift.balance / 100.0
        json[:available_balance] = json[:balance]
        json[:available_balance] = last_redemption.gift_next_value  if last_redemption.present?

        render json: {status: 1, data: json.as_json}
    end


    # GET  /papergifts/:id
    def paper_cert
        # Publicly-accessible API despite the controller location
        puts "[api Papergifts :: paper_cert]  params: #{params.inspect}"

        # Fully redeemed gift?
        if @gift.status == 'redeemed'

            @redemptions = @gift.redemptions.reverse
            respond_to do |format|
                format.html do
                    render template: "papergifts/gift_already_redeemed", encoding: :utf8, formats: [:html]
                end
                format.pdf do
                    # Because for some reason I must specify the template in both places, or it renders 'paper_cert.erb' instead :/
                    render pdf: "papergifts/gift_already_redeemed", template: "papergifts/gift_already_redeemed", encoding: :utf8, formats: [:pdf]
                end
            end
            return
        end

        # Otherwise-invalid gift?
        raise ActiveRecord::RecordNotFound  unless @gift.kind_of?(Gift)  if invalid_gift_status?


        @hand_delivery = (@gift.status == 'hand_delivery')

        # Create redemption of the appropriate type
        type = :paper
        type = :hand_delivery  if @hand_delivery
        resp = Redeem.start(gift: @gift, api: "/papergifts/#{params[:id]}", type_of: type)
        unless resp['success']
            # Something's amiss.
            render :text => resp['response_text']  and return
        end

        # 'Kay, everything's coo'
        # Pluck out the data needed to build the cert
        @redemption = resp['redemption']
        @gift       = resp['gift']        ##?  Doesn't this point at the same gift?
        @items      = @gift.cart.map{|item| "#{item['quantity']}x #{item['item_name']}" }

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
    end

private

    def resolve_gift
        @gift = Gift.includes(:merchant).find_with(params[:id]) rescue nil

        raise ActiveRecord::RecordNotFound  unless @gift.kind_of?(Gift)
    end

    def invalid_gift_status?
        !['hand_delivery', 'incomplete', 'open', 'notified', 'schedule'].include?(@gift.status)
    end

end
