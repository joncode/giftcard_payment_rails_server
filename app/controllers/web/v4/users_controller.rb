class Web::V4::UsersController < MetalCorsController
  before_action :authentication_token_required


  # PATCH  /web/v4/users/:id
  def update
    # Copied basically wholesale from Web::V3::UsersController#update
    # This could use significant cleanup, but according to sales/"bizteam", refactoring is a WasteOfTime (tm) -- at least until it slows development of their shiny new features.  In which case it's my fault for not doing it, of course.

    _signature = "[api Web::V4::UsersController :: update]"
    puts "\n\n#{_signature}"
    puts " | user_id: #{@current_user.id}"
    puts " | params:  #{update_user_params.inspect}"

    user    = @current_user
    updates = update_user_params

    if updates["photo"]
      updates["iphone_photo"] = updates["photo"]
    end
    updates.delete("photo")
    error_hsh = {}

    if updates["birthday"].present?
      begin
        r = Date.strptime(updates["birthday"], "%m/%d/%Y")
      rescue
        if r.nil?
          error_hsh['birthday'] = 'is invalid'
        end
      end
    end

    if updates["social"].present?
      updaters = updates["social"].select{|u| u["_id"] }
      newbies  = updates["social"].select{|u| u["net"] }

      ids = updaters.map{|social| social["_id"]}
      user_socials  = UserSocial.where(id: ids)
      updaters.each do |social|
        us = user_socials.where(id: social["_id"]).first
        us.set_primary  if social["primary"]  ##? Will this be a bool or a string?
        unless us.update(identifier: social["value"])
          error_hsh.merge!(us.errors.messages)
        end
      end

      if error_hsh.empty?
        newbies.each do |social|
          type_of = case social["net"]
                    when 'ph'
                      "phone"
                    when 'fb'
                      "facebook_id"
                    when 'tw'
                      "twitter"
                    when 'em'
                      "email"
                    end
          us = UserSocial.new(user_id: @current_user.id, type_of: type_of, identifier: social["value"])
          if us.save
            us.set_primary  if social["primary"]  ##? Will this be a bool or a string?
          else
            error_hsh.merge!(us.errors.messages)
          end
        end
      end
      updates.delete("social")
      UserSocial.ensure_primaries(@current_user.id)  # Set default primaries, if applicable
    end
    if error_hsh.empty? && user.update(updates)
      success user.login_client_serialize
    else
      error_hsh.merge!(user.errors.messages)
      fail_web fail_web_payload("not_created_user", error_hsh)
    end

    respond(status)
  end


private


  def update_user_params
    params.require(:data).permit("first_name", "last_name", "sex", "birthday", "zip", "photo", "social" => %w[net _id value primary], oauth: [:token, :secret, :net, :net_id, :handle, :photo] )
  end


end
