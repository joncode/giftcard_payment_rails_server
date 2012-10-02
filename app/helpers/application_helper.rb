module ApplicationHelper
  
  def merchant_tag(user)
    if user.providers
      link_to "Merchant Sign In", merchants_path      
    else
      link_to "Merchant Sign Up", new_provider_path
    end
  end
 
  def custom_image_tag(object,width,height)
    if object.photo.blank?
      if object.kind_of? User
        photo = "http://res.cloudinary.com/drinkboard/image/upload/c_fill,h_#{height},w_#{width}/v1349148077/ezsucdxfcc7iwrztkags.png"
      else
        photo = "http://res.cloudinary.com/drinkboard/image/upload/c_fill,h_#{height},w_#{width}/v1349150293/upqygknnlerbevz4jpnw.png"
      end
    else
      photo_url = object.photo.dup.to_s
      photo_array = photo_url.split('upload/')
      photo = "http://res.cloudinary.com/drinkboard/image/upload/c_fill,h_#{height},w_#{width}/#{photo_array[1]}"      
    end 
    image_tag(photo, alt: "customImageTag", :class => 'gravatar' )
  end

end
