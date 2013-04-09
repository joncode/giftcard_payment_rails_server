module ApplicationHelper
  
  def merchant_tag(user)
    if user.providers 
      link_to "Merchant Log In", merchants_path      
    else
      #link_to "Merchant Home", merchant_path(@provider)
    end
  end

  def custom_image_tag(object,width,height,flag=nil) 
      crop  = "/c_fill,h_#{height},w_#{width},a_exif/"
      if flag 
        photo     = object.get_image(flag)
        url_array = photo.split('upload/') 
      else
        url_array = object.get_photo_for_web.split('upload/')
      end
      if url_array.count > 1
          # if split on upload is successful then its cloudinary and build 
        photo = url_array[0] + 'upload' + crop + url_array[1]
      else
          # if split is unsuccessful - it is a twitter or fb photo, the url is already built
        photo = url_array[0]
      end
      image_tag(photo, alt: "noImage", :class => "customImageTag", :style => "height:#{height}px;width:#{width}px;" )
  end

  def print_gift_status gift
    case gift.status
    when 'open'
      "New"
    when 'notified'
      "Redeem"
    when 'redeemed'
      "Details"
    else
      "Regifted"
    end
  end

  def time_and_date_official
    "%l:%M %p - %A, %B %e"
  end

  def human_readable_error_message obj
      messages = obj.errors.messages
      message_ary = ["Error! Data not saved"]
      messages.each_key do |k|
        if k != :password_digest
          values = messages[k]
          values.each do |v|
            human_str = "#{k.to_s} "
            human_str += v
            message_ary << human_str
          end 
        end
      end
      return message_ary
    end
end
