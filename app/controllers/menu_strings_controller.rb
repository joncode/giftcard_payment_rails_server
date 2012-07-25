class MenuStringsController < ApplicationController
  # GET /menu_strings
  # GET /menu_strings.json
  def index
    @menu_strings = MenuString.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @menu_strings }
    end
  end

  # GET /menu_strings/1
  # GET /menu_strings/1.json
  def show
    @menu_string = MenuString.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @menu_string }
    end
  end

  # GET /menu_strings/new
  # GET /menu_strings/new.json
  def new
    @menu_string = MenuString.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @menu_string }
    end
  end

  # GET /menu_strings/1/edit
  def edit
    @menu_string = MenuString.find(params[:id])
  end

  # POST /menu_strings
  # POST /menu_strings.json
  def create
    @menu_string = MenuString.new(params[:menu_string])

    respond_to do |format|
      if @menu_string.save
        format.html { redirect_to @menu_string, notice: 'Menu string was successfully created.' }
        format.json { render json: @menu_string, status: :created, location: @menu_string }
      else
        format.html { render action: "new" }
        format.json { render json: @menu_string.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /menu_strings/1
  # PUT /menu_strings/1.json
  def update
    @menu_string = MenuString.find(params[:id])

    respond_to do |format|
      if @menu_string.update_attributes(params[:menu_string])
        format.html { redirect_to @menu_string, notice: 'Menu string was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @menu_string.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /menu_strings/1
  # DELETE /menu_strings/1.json
  def destroy
    @menu_string = MenuString.find(params[:id])
    @menu_string.destroy

    respond_to do |format|
      format.html { redirect_to menu_strings_url }
      format.json { head :no_content }
    end
  end
end
