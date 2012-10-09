module ApplicationHelper
  
  def merchant_tag(user)
    if user.providers
      link_to "Merchant Sign In", merchants_path      
    else
      link_to "Merchant Sign Up", new_provider_path
    end
  end

  def custom_image_tag(object,width,height)
    crop = "/c_fill,h_#{height},w_#{width}/"
    if object.kind_of? Provider
      photo = "#{CLOUDINARY_IMAGE_URL}" + crop + "v1349150293/upqygknnlerbevz4jpnw.png"
    else
      url_array = object.get_photo.split('upload/')
      photo     = url_array[0] + 'upload' + crop + url_array[1]
    end 
    image_tag(photo, alt: "customImageTag3", :class => 'customImageTag' )
  end

end
