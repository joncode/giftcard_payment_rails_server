class RedeemsController < ApplicationController

  def index
    @redeems = Redeem.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @redeems }
    end
  end

  def show
    @redeem = Redeem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @redeem }
    end
  end

  def new
    @redeem = Redeem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @redeem }
    end
  end

  def edit
    @redeem = Redeem.find(params[:id])
  end

  def create
    @redeem = Redeem.new(params[:redeem])

    respond_to do |format|
      if @redeem.save
        format.html { redirect_to @redeem, notice: 'Redeem was successfully created.' }
        format.json { render json: @redeem, status: :created, location: @redeem }
      else
        format.html { render action: "new" }
        format.json { render json: @redeem.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @redeem = Redeem.find(params[:id])

    respond_to do |format|
      if @redeem.update_attributes(params[:redeem])
        format.html { redirect_to @redeem, notice: 'Redeem was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @redeem.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @redeem = Redeem.find(params[:id])
    @redeem.destroy

    respond_to do |format|
      format.html { redirect_to redeems_url }
      format.json { head :no_content }
    end
  end
end
