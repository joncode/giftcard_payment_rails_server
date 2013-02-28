class MerchantsController < ApplicationController
    include SubtleDataHelper
    ACTIONS_WITH_HEADERS = [ :help, :explorer, :pos, :menujs, :menu, :edit_photo, :menu_builder, :show, :photos, :edit_info, :edit_bank, :update, :orders, :past_orders, :redeem, :completed, :customers, :staff_profile, :staff ]
    ACTIONS_WITHOUT_HEADERS = [:update_item, :delete_item, :index, :get_cropper, :add_employee, :remove_employee  ]
    before_filter :signed_in_user
    before_filter :populate_locals, only: ACTIONS_WITH_HEADERS

    # test methods
    def help
    end

    def explorer
        @explorer = params["name"].split(".html")[0]
    end

    def pos
        @vars = SDRequest.new({}).serialize
    end

    def menujs
        @menu_array     = Menu.get_menu_array_for_builder @provider
        column = 1
        @left = []
        @right = []
        @menu_array.each do |m|
          if column == 1
            @left << m
            column = 2
          else
            @right << m 
            column = 1
          end
        end
        @menu_array = @menu_array.to_json
    end

    # end test methods

    def compile_menu
      @provider = Provider.find(params[:id])
      
      respond_to do |format|
        if MenuString.compile_menu_to_menu_string(@provider.id)
          # update the menu string to show the menustring is up to date 
          # render success
            @message = "Merchant Menu on App is Updated and Now Live"
            @go_live = "live_menu_notice"
            format.js 
        else
          # render error
          @message = human_readable_error_message menu_string
          format.js { render 'compile_error'}
        end
      end
    end

    def update_item
        puts "update item => #{params}"
        if params[:item_id]
          @menu = Menu.find(params[:item_id])
        else
          @menu = Menu.new
          @menu.provider_id = params[:id]
          @menu.section = params[:section]
        end
        @menu.item_name = params[:item_name]
        @menu.description = params[:description]
        @menu.price = params[:price]
        respond_to do |format|
          if @menu.save
            @menu.provider.update_attribute(:menu_is_live, false)
            # response = {"success" => "Menu Item Saved!"}
            @message = "#{@menu.item_name} Updated"
            @go_live = "compile_menu_button"
            format.js { render 'compile_menu'}
          else
            @message = human_readable_error_message @menu
            format.js { render 'compile_error'}
          end
        end
    end

    def delete_item
        puts "delete item => #{params}"
        item = Menu.find(params[:item_id])

        respond_to do |format|
          if item.update_attributes({active: false})
            item.provider.update_attribute(:menu_is_live, false)
            # response = {"success" => "Menu Item Deactivated"}
            @message = "#{item.item_name} De-Activated"
            @go_live = "compile_menu_button"
            format.js { render 'compile_menu'}
          else
            @message = human_readable_error_message @menu
            format.js { render 'compile_error'}
          end
        end
    end

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
        @menu_array     = Menu.get_menu_array_for_builder @provider
        column = 1
        @left = []
        @right = []
        @menu_array.each do |m|
          if column == 1
            @left << m
            column = 2
          else
            @right << m 
            column = 1
          end
        end
    end

    def menu_builder
      
    end

    def show
    end

    def photos
        redirect_to  edit_photo_merchant_path(@provider)
    end

    def get_cropper
        @image = params["image"]
        @obj_to_edit = current_user
        @obj_name = "user"
        @action = "update_avatar"
        @controller = "users"
        @file_field_name = @image.dup
        if @image == 'secure_image'
          @image = 'Secure Image'
        else 
          @image = "Photo"
        end
        @obj_width = 131
        @obj_height = 131

        respond_to do |format|
          format.js
        end
    end

    def edit_photo
        @obj_to_edit = @provider
        @obj_name = "provider"
        @file_field_name = "photo"
        @obj_width = 600
        @obj_height = 320
        @action = "update_photos"
    end

    def update_photos
        @provider.update_attributes(params[:provider])
        redirect_to photos_merchant_path(@provider)
    end

    def edit_info
    end

    def edit_bank
    end

    def update

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
        @gifts = Gift.get_all_orders(@provider)

        respond_to do |format|
          if @gifts.nil?
            format.html 
          else
            format.html # index.html.erb
            format.js
            format.json { render json: @gifts }
          end
        end
    end

    def past_orders
        @gifts = Gift.get_history_provider(@provider)

        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @gifts }
        end
    end

    def redeem
        @gift     = Gift.find(params[:gift_id])
        @redeem   = Redeem.find_by_gift_id(@gift)
        @employee = Employee.where(user_id: current_user.id, provider_id: @provider.id)[0]

        if @redeem
          @order  = Order.new(redeem_id: @redeem.id, gift_id: @gift.id, provider_id: @provider.id, employee_id: @employee.id)
        else
          # no redeem = no order possible
          @order  = Order.new
        end

        respond_to do |format|
          format.html # show.html.erb
          format.js { render 'order'}
          format.json { render json: @redeem }
        end
    end

    def completed
        @gift     = Gift.find(params[:gift_id])
        @giver    = @gift.giver
        @receiver = @gift.receiver
        @order    = @gift.order
        if @order.server_id
          @server = User.find(@order.server_id) 
        else
          @server = User.new(first_name: "missing", last_name: "person")
        end
        respond_to do |format|
          format.html # detail.html.erb
          format.js
          format.json { render json: @gift }
        end
    end

    def customers
        @users    = (@current_user.blank? ? User.all : User.find(:all, :conditions => ["id != ?", @current_user.id]))
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
        @staff    = @provider.employees
        @nonstaff = @provider.users_not_staff
    end

    def staff_profile
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

    def add_member
        user = User.find params[:user_id]
        emp = Employee.create(user_id: user.id, provider_id: @provider.id) 
        redirect_to staff_merchant_path(@provider)
    end

    def invite_employee
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

    private

      def populate_locals
        @provider       = Provider.find(params[:id])
        @current_user   = current_user
      end

end
