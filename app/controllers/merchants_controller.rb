
class MerchantsController < ApplicationController
  
  def index
    @providers = current_user.providers    

    respond_to do |format|
      if @providers.count == 1
        format.html { redirect_to merchant_path(@providers.pop) }
      else
        format.html
      end
    end
  end

  def menu
    @provider = Provider.find(params[:id])
    @current_user = current_user
    @menu_string = MenuString.get_menu_for_provider(@provider)
    @menu = JSON.parse @menu_string
    @sections = Menu.get_sections(@provider)
    puts "MENU ARRAY !!! = " + @menu.inspect
    puts "SECTIONS ARRAY = "  + @sections.inspect  
    ##### what do we need for the data to seed this view
    # the sections need to go into each title bar
    # the different array hashes need to be sorted into each section
    # the data needs to be written into each section as holder data
    # the id for each product needs to be hidden for each product
  end

  def show
    @provider = Provider.find(params[:id])
    @current_user = current_user
    @menu = create_menu_from_items(@provider)
    @gifts = Gift.get_activity_at_provider(@provider)
  end

  def edit_photo
    @provider = Provider.find(params[:id])
    @current_user = current_user
  end

  def edit_info
    @provider = Provider.find(params[:id])
    @current_user = current_user
  end

  def edit_bank
    @provider = Provider.find(params[:id])
    @current_user = current_user
  end

  def update
    @provider = Provider.find(params[:id])

    respond_to do |format|
      if @provider.update_attributes(params[:provider])
        format.html { redirect_to @provider, notice: 'Provider was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @provider.errors, status: :unprocessable_entity }
      end
    end    
  end

  def orders
    @provider = Provider.find(params[:id])
    @gifts = Gift.get_all_orders(@provider)
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gifts }
    end
  end

  def past_orders
    @provider = Provider.find(params[:id])
    @gifts = Gift.get_history_provider(@provider)
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gifts }
    end
  end

  def detail
    @gift = Gift.find(params[:id])
    @giver = @gift.giver
    @receiver = @gift.receiver
    @provider = @gift.provider
    if @gift.order.server_id
      @server = User.find(@gift.order.server_id) 
    else
      @server = User.new(first_name: "missing", last_name: "person")
    end
    respond_to do |format|
      format.html # detail.html.erb
      format.json { render json: @gift }
    end
  end

  def order
    @gift = Gift.find(params[:id])
    @redeem = Redeem.find_by_gift_id(@gift)
    @provider = @gift.provider
    
    if @redeem
      @order = Order.new(redeem_id: @redeem.id, gift_id: @gift.id, server_id: current_user.id, provider_id: @provider.id)
    else
      # no redeem = no order possible
      @order = Order.new
    end


    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @redeem }
    end
  end
  
  def completed
    @order = Order.find(params[:id])
    @gift = @order.gift
    @giver = @gift.giver
    @receiver = @gift.receiver
    @provider = @order.provider
    if @order.server_id
      @server = User.find(@order.server_id) 
    else
      @server = User.new(first_name: "missing", last_name: "person")
    end
    respond_to do |format|
      format.html # detail.html.erb
      format.json { render json: @gift }
    end
  end

  def customers
    @provider = Provider.find(params[:id])    
    @user     = current_user
    @users    = (current_user.blank? ? User.all : User.find(:all, :conditions => ["id != ?", current_user.id]))
    # list customers on the screen with most recent activity first
        # most drinks ordered
        # most money spent
    # check all the gifts , get the giver and receiver user ids
    # assign those ids to the gift.updated_at field 
    # make a uniq array of all user ids
    # remove employees from that list 
    # list those customers on the screen by gift.updated_at
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def staff
    @provider = Provider.find(params[:id])
    @staff    = @provider.users
  end

  def add_employee
    return redirect_to "/" if !params[:join_token] && !params[:email]

    provider = Provider.find_by_join_token(params[:join_token])
    return redirect_to "/" if !provider
    
    user = User.find_by_email(params[:email])
    return redirect_to "/" if !user
    
    #Otherwise, put the user in the employees hash.
    provider.employees << user
    flash[:notice] = "You successfully joined #{provider.name}."
    redirect_to "/"
  end

  def invite_employee
    @provider = Provider.find(params[:id])
    if request.get?
      #Show the page.
    elsif request.post?
      #Find the user, etc
      if !params[:email]
        return flash[:notice] = "You must enter in a user email."
      end
      potential_employee = User.find_by_email(params[:email])
      if !potential_employee
        #If the user doesn't exist in the database
      else
        #The user does exist in the database        
      end
      #For now, we handle either situation the same
      Resque.enqueue(EmailJob, 'invite_employee', current_user.id, {:provider_id => @provider.id, :email => params[:email]})
    end
  end
  
  def remove_employee
    #REMOVE THIS RETURN STATEMENT TO HAVE THE LINK FUNCTION PROPERLY.
    return redirect_to "/merchants/#{params[:id]}/staff"
    if params[:eid]
      provider = Provider.find(params[:id])
      provider.employees.each do |employee|
        if ""+employee.user_id == ""+params[:id]
          provider.employees.delete(employee)
          provider.save
          break
        end
      end
    end
    redirect_to "/merchants/#{params[:id]}/staff"
  end

end
