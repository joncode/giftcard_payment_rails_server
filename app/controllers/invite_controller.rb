class InviteController < ApplicationController
  
  def show
    number = 49387
    # remove the permalink from the id
    @gift = Gift.find(params[:id])
    @giver = @gift.giver

    respond_to do |format|
      format.html # detail.html.erb
      format.json { render json: @gift }
    end

  end
  
end
