class Web::V4::SocialsController < MetalCorsController
  before_action :authentication_token_required


  # POST  /web/v4/socials/:social_id/primary
  def set_primary
    _signature = "\n\n[api Web::V4::SocialsController :: set_primary(#{params[:social_id]})]"
    social = UserSocial.where(user_id: @current_user.id, id: params[:social_id]).first

    if social.nil?
      puts "#{_signature}  Record not found"
      fail_web({err: "INVALID_INPUT", msg: "The specified record does not exist."}) and return
    end

    unless social.set_primary
      puts "#{_signature}  Unable to update record"
      fail_web({err: "500_INTERNAL", msg: "Unable to set your primary contact information.  Please try again later."}) and return
    end

    puts "#{_signature}  Set as primary"
    success(social.serializable_hash)

  ensure
    respond
  end

end
