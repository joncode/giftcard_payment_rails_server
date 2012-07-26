class GiftsController < ApplicationController

  def index
    @gifts = Gift.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gifts }
    end
  end

  def show
    @gift = Gift.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gift }
    end
  end

  def new
    @gift = Gift.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gift }
    end
  end

  def edit
    @gift = Gift.find(params[:id])
  end

  def create
    @gift = Gift.new(params[:gift])

    respond_to do |format|
      if @gift.save
        format.html { redirect_to @gift, notice: 'Gift was successfully created.' }
        format.json { render json: @gift, status: :created, location: @gift }
      else
        format.html { render action: "new" }
        format.json { render json: @gift.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @gift = Gift.find(params[:id])

    respond_to do |format|
      if @gift.update_attributes(params[:gift])
        format.html { redirect_to @gift, notice: 'Gift was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @gift.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @gift = Gift.find(params[:id])
    @gift.destroy

    respond_to do |format|
      format.html { redirect_to gifts_url }
      format.json { head :no_content }
    end
  end
end
