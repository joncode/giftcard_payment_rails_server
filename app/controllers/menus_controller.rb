class MenusController < ApplicationController

  def index
    @menus = Menu.where(acive: true)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @menus }
    end
  end

  def show
    provider = Provider.find(params[:id])
    @menu = provider.menu

    respond_to do |format|
      format.html 
      format.json { render json: @menu }
    end
  end

  def new
    @menu = Menu.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @menu }
    end
  end

  def edit
    menu_obj = Menu.find params[:id]
    provider_id = menu_obj.provider_id
    @provider = Provider.find provider_id
    @current_user = current_user
    @menu_string = MenuString.get_menu_for_provider(provider_id)
    @menu = JSON.parse @menu_string
    @sections = Menu.get_sections(provider_id)
    puts "MENUSTRING --> " + @menu_string
    puts "MENU ARRAY !!! = " + @menu.inspect
    puts "SECTIONS ARRAY = "  + @sections.inspect
  end

  def create
    @menu = Menu.new(params[:menu])

    respond_to do |format|
      if @menu.save
        format.html { redirect_to @menu, notice: 'Menu was successfully created.' }
        format.json { render json: @menu, status: :created, location: @menu }
      else
        format.html { render action: "new" }
        format.json { render json: @menu.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @menu = Menu.find(params[:id])

    respond_to do |format|
      if @menu.update_attributes(params[:menu])
        format.html { redirect_to @menu, notice: 'Menu was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @menu.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @menu = Menu.find(params[:id])
    @menu.destroy

    respond_to do |format|
      format.html { redirect_to menus_url }
      format.json { head :no_content }
    end
  end
end
