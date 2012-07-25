class RedeemsController < ApplicationController
  # GET /redeems
  # GET /redeems.json
  def index
    @redeems = Redeem.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @redeems }
    end
  end

  # GET /redeems/1
  # GET /redeems/1.json
  def show
    @redeem = Redeem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @redeem }
    end
  end

  # GET /redeems/new
  # GET /redeems/new.json
  def new
    @redeem = Redeem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @redeem }
    end
  end

  # GET /redeems/1/edit
  def edit
    @redeem = Redeem.find(params[:id])
  end

  # POST /redeems
  # POST /redeems.json
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

  # PUT /redeems/1
  # PUT /redeems/1.json
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

  # DELETE /redeems/1
  # DELETE /redeems/1.json
  def destroy
    @redeem = Redeem.find(params[:id])
    @redeem.destroy

    respond_to do |format|
      format.html { redirect_to redeems_url }
      format.json { head :no_content }
    end
  end
end
