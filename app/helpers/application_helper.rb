module ApplicationHelper
  
  def merchant_tag(user)
    if user.providers
      link_to "Merchant Sign In", merchants_path      
    else
      link_to "Merchant Sign Up", new_provider_path
    end
  end
 
  # def custom_image_tag(object,width,height)
  #   if object.photo.blank?
  #     if object.kind_of? User
  #       photo = "#{CLOUDINARY_IMAGE_URL}/c_fill,h_#{height},w_#{width}/v1349148077/ezsucdxfcc7iwrztkags.png"
  #     else
  #       photo = "#{CLOUDINARY_IMAGE_URL}/c_fill,h_#{height},w_#{width}/v1349150293/upqygknnlerbevz4jpnw.png"
  #     end
  #   else
  #     photo_url   = object.photo.dup.to_s
  #     photo_array = photo_url.split('upload/')
  #     photo = "#{CLOUDINARY_IMAGE_URL}/c_fill,h_#{height},w_#{width}/#{photo_array[1]}"      
  #   end 
  #   image_tag(photo, alt: "customImageTag", :class => 'customImageTag' )
  # end

  def custom_image_tag(object,width,height)
    if object.kind_of? Provider
      photo = "#{CLOUDINARY_IMAGE_URL}/c_fill,h_#{height},w_#{width}/v1349150293/upqygknnlerbevz4jpnw.png"
    else
      photo = choose_photo(object, width, height)
    end 
    image_tag(photo, alt: "customImageTag", :class => 'customImageTag' )
  end

  def choose_photo(object, width, height)
    case object.use_photo
    when "cw"
      photo_url   = object.photo.dup.to_s
      photo_array = photo_url.split('upload/')
      "#{CLOUDINARY_IMAGE_URL}/c_fill,h_#{height},w_#{width}/#{photo_array[1]}" 
    when "ios"
      object.iphone_photo
    when "fb"
      # object.fb_photo
      # need to add code for fb photo store and use  
      "#{CLOUDINARY_IMAGE_URL}/c_fill,h_#{height},w_#{width}/v1349148077/ezsucdxfcc7iwrztkags.png"
    else
      if object.photo.blank?
        "#{CLOUDINARY_IMAGE_URL}/c_fill,h_#{height},w_#{width}/v1349148077/ezsucdxfcc7iwrztkags.png"
      else
        photo_url   = object.photo.dup.to_s
        photo_array = photo_url.split('upload/')
        "#{CLOUDINARY_IMAGE_URL}/c_fill,h_#{height},w_#{width}/#{photo_array[1]}"
      end
    end
  end


end
