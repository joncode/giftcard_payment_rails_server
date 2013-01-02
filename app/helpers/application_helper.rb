module ApplicationHelper
  
  def merchant_tag(user)
    if user.providers
      link_to "Merchant Log In", merchants_path      
    else
      #link_to "Merchant Sign Up", new_provider_path
    end
  end

  def custom_image_tag(object,width,height,flag=nil)
    crop  = "/c_fill,h_#{height},w_#{width}/"
    if flag
      photo     = object.get_image(flag)
      url_array = photo.split('upload/')
    else
      url_array = object.get_photo.split('upload/')
    end
    photo = url_array[0] + 'upload' + crop + url_array[1]
    image_tag(photo, alt: "customImageTag4", :class => 'customImageTag' )
  end

end
