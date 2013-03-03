module ApplicationHelper
  
  def merchant_tag(user)
    if user.providers 
      link_to "Merchant Log In", merchants_path      
    else
      #link_to "Merchant Home", merchant_path(@provider)
    end
  end

  def custom_image_tag(object,width,height,flag=nil)
    crop  = "/c_fill,h_#{height},w_#{width}/"
    if flag 
      photo     = object.get_image(flag)
      url_array = photo.split('upload/')
    else
      url_array = object.get_photo_for_web.split('upload/')
    end
    photo = url_array[0] + 'upload' + crop + url_array[1]
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
end
