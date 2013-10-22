# class LocationsController < ApplicationController
#   # ##### Location functions are for a specific USER.
#   # def map
#   # end

#   # def mapForUserWithinBoundary
#   #   if !required_params ['top_lat', 'bot_lat', 'left_lng', 'right_lng']
#   #     return render json: {error: {errorDesc: "Boundary parameters do not exist in the call."}}
#   #   end

#   #   thisUser = getUser
#   #   if !thisUser
#   #     return render json: {error: {errorDesc: "User not found."}}
#   #   end

#   #   bounds = {botLat: params[:bot_lat].to_f, topLat: params[:top_lat].to_f, leftLng: params[:left_lng].to_f, rightLng: params[:right_lng].to_f}
#   #   puts bounds
#   #   #All of the provider locations based on the boundary
#   #   @providers = Provider.allWithinBounds(bounds)

#   #   #All of the users' following people within the boundary
#   #   # no followed user implemented yet HACK <<<<<<<
#   #   followedUserIds = User.all.map { |u| u.id }
#   #   ##followedUserIds = User.find(thisUser.id).followed_users.map{ |user| user.id }

#   #   @followedUsers = Location.allUsersWithinBounds(followedUserIds, bounds)

#   #   #Only render in JSON
#   #   return render json: { providers: @providers, followedUsers: @followedUsers}
#   # end

#   # #####Handle subscriptions
#   # ###
#   # ##
#   # #Facebook
#   # def validateFacebookSubscription
#   #   ret = ""
#   #   if !params["hub.mode"] || !params["hub.challenge"] || !params["hub.verify_token"]
#   #     ret = "Not enough parameters."
#   #   elsif params["hub.mode"]  != "subscribe"
#   #    ret = "Hub mode is not subscribe."
#   #   elsif  params["hub.verify_token"] != "drinkboard4eva!!1"
#   #     ret = "Verify token does not match."
#   #   else
#   #     ret = params["hub.challenge"]
#   #   end
#   #   return render :text => ret
#   # end

#   # def realTimeFacebookUpdate
#   #   if !params["object"] || !params["entry"]
#   #     return render :text => "Facebook realtime update is incomplete."
#   #   elsif params["object"] != "user"
#   #     return render :text => "User object is not being updated."
#   #   end

#   #   #For now, assume that fbuser["changed_fields"] is always checkins because that's all we are subscribing to.
#   #   params["entry"].each do |fbuser|
#   #     user = User.find_by_facebook_id_and_facebook_auth_checkin(fbuser["uid"],true)
#   #     fbRequest = "https://graph.facebook.com/me/checkins?access_token=#{user[:facebook_access_token]}&limit=1"   #Latest checkin only.
#   #     fbResponse = HTTParty.get(fbRequest)
#   #     fbResponse["data"].each do |checkin|
#   #       if user[:is_public]
#   #         Location.createWithFacebookCheckin(checkin,user)
#   #       end
#   #     end
#   #   end

#   #   return render :text => "Success"
#   # end

#   # #Foursquare
#   # def realTimeFoursquareUpdate
#   #   checkin = params["checkin"]
#   #   if !checkin
#   #     return render :text => "No response object to parse."
#   #   end
#   #   user = User.find_by_foursquare_id(checkin["user"]["id"])
#   #   if user && user[:is_public]
#   #     Location.createWithFoursquareCheckin(checkin,user)
#   #   end
#   #   return render :text => "Success"
#   # end

#   # def logLocation
#   #   thisUser = getUser
#   #   if !thisUser
#   #     return render json: {error: {errorDesc: "User not found."}}
#   #   end

#   #   newLocHash = []
#   #   if params[:isFirstCheckin]
#   #     thisUser.currently_out = true
#   #     thisUser.save
#   #     newLocHash[:first_checkin] = true
#   #   end

#   #   if params[:lat] && params[:lng] && (params[:fsq_id] || params[:fb_id])
#   #     newLocHash[:latitude] = params[:lat]
#   #     newLocHash[:longitude] = params[:lng]
#   #     newLocHash[:foursquare_venue_id] = params[:fsq_id] if params[:fsq_id]
#   #     newLocHash[:facebook_venue_id] = params[:fb_id] if params[:fb_id]
#   #     #Look to see if a provider matches the facebook or fsq id
#   #     provider = Provider.where("foursquare_venue_id = ? OR facebook_venue_id = ?",params[:fsq_id],params[:fb_id])
#   #     newLocHash[:provider_id] = provider.id
#   #   end

#   #   @location = Location.create(newLocHash)
#   # end

#   # def turnOffUserLocation
#   #   thisUser = getUser
#   #   if !thisUser
#   #     return render json: {error: {errorDesc: "User not found."}}
#   #   end

#   #   thisUser.currently_out = false
#   #   thisUser.save
#   # end


#   # def checkinUser
#   #   if !required_params ['lat', 'lng', 'foursquare_id']        #Optional params: provider_id
#   #     return render json: {error: {errorDesc: "Boundary parameters do not exist in the call."}}
#   #   end

#   #   thisUser = getUser
#   #   if !thisUser
#   #     return render json: {error: {errorDesc: "User not found."}}
#   #   end

#   #   @user = User.find(thisUser.id)
#   #   if !@user[:foursquare_id]
#   #     return render json: {error: {errorDesc: "User does not have foursquare enabled."}}
#   #   end
#   #   if !@user.checkin_to_foursquare(params[:foursquare_id],params[:lat],params[:lng])
#   #     return render json: {error: {errorDesc: "There was an error checking into foursquare."}}
#   #   end

#   #   newLocHash = {:user_id => thisUser.id, :latitude => params[:lat], :longitude => [:lng], :foursquare_venue_id => params[:foursquare_id]}
#   #   newLocHash[:provider_id] = params[:provider_id] if params[:provider_id]
#   #   @newLoc = Location.new(newLocHash)

#   #   respond_to do |format|
#   #     format.html #map.html.erb
#   #     format.json {render json: @newLoc}
#   #   end
#   # end

#   # def getUser
#   #   if current_user
#   #     return current_user
#   #   elsif !current_user && params["token"]
#   #     return User.find_by_remember_token(params["token"])
#   #   else
#   #     return nil
#   #   end
#   # end
#   # ###END Location functions for a specific user



#   # # GET /locations/1
#   # # GET /locations/1.json
#   # def show
#   #   @location = Location.find(params[:id])

#   #   respond_to do |format|
#   #     format.html # show.html.erb
#   #     format.json { render json: @location }
#   #   end
#   # end

#   # # GET /locations/new
#   # # GET /locations/new.json
#   # def new
#   #   @location = Location.new

#   #   respond_to do |format|
#   #     format.html # new.html.erb
#   #     format.json { render json: @location }
#   #   end
#   # end

#   # # GET /locations/1/edit
#   # def edit
#   #   @location = Location.find(params[:id])
#   # end

#   # # POST /locations
#   # # POST /locations.json
#   # def create
#   #   @location = Location.new(params[:location])

#   #   respond_to do |format|
#   #     if @location.save
#   #       format.html { redirect_to @location, notice: 'Location was successfully created.' }
#   #       format.json { render json: @location, status: :created, location: @location }
#   #     else
#   #       format.html { render action: "new" }
#   #       format.json { render json: @location.errors, status: :unprocessable_entity }
#   #     end
#   #   end
#   # end

#   # # PUT /locations/1
#   # # PUT /locations/1.json
#   # def update
#   #   @location = Location.find(params[:id])

#   #   respond_to do |format|
#   #     if @location.update_attributes(params[:location])
#   #       format.html { redirect_to @location, notice: 'Location was successfully updated.' }
#   #       format.json { head :no_content }
#   #     else
#   #       format.html { render action: "edit" }
#   #       format.json { render json: @location.errors, status: :unprocessable_entity }
#   #     end
#   #   end
#   # end

#   # # DELETE /locations/1
#   # # DELETE /locations/1.json
#   # def destroy
#   #   @location = Location.find(params[:id])
#   #   @location.destroy

#   #   respond_to do |format|
#   #     format.html { redirect_to locations_url }
#   #     format.json { head :no_content }
#   #   end
#   # end
# end
