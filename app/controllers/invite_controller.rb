class InviteController < ApplicationController
  
  def show
    number = 649387
    # remove the permalink from the id
    id = params[:id].to_i - number
    @gift = Gift.find(id)
    @giver = @gift.giver

    respond_to do |format|
      format.html # detail.html.erb
      format.json { render json: @gift }
    end

  end
  
end
