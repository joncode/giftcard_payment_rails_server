module UsersHelper
  
  def gravatar_for(user)
    width   = 75
    height  = 100
    if user.photo.blank?
      photo = "http://res.cloudinary.com/htaaxtzcv/image/upload/c_fill,h_#{height},w_#{width}/v1349148077/ezsucdxfcc7iwrztkags.png"
      image_tag(photo, alt: "hello",:class => 'gravatar' )
    else
      image_tag(user.photo_url(:gravatar), :width => width, :height => height)
    end   
  end

  def list_standard_icon_for(user)
    width   = 150
    height  = 150
    if user.photo.blank?
      photo = "http://res.cloudinary.com/htaaxtzcv/image/upload/c_fill,h_#{height},w_#{width}/v1349148077/ezsucdxfcc7iwrztkags.png"
      image_tag(photo, alt: "hello",:class => 'gravatar' )
    else
      image_tag(user.photo_url(:standard), :width => width, :height => height)
    end   
  end
  
  def list_icon_for(user)
    width   = 50
    height  = 50
    if user.photo.blank?
      photo = "http://res.cloudinary.com/htaaxtzcv/image/upload/c_fill,h_#{height},w_#{width}/v1349148077/ezsucdxfcc7iwrztkags.png"
      image_tag(photo, alt: "hello",:class => 'gravatar' )
    else
      image_tag(user.photo_url(:thumbnail), :width => width, :height => height)
    end   
  end
  
  def list_icon_with_id_for(user_id)
    if user_id.nil? 
      user = User.new
    else
      user = User.find(user_id)
    end
    list_icon_for user  
  end
  
  def custom_image_tag(user,width,height)
    if user.photo.blank?
      photo = "http://res.cloudinary.com/drinkboard/image/upload/c_fill,h_#{height},w_#{width}/v1349148077/ezsucdxfcc7iwrztkags.png"
    else
      photo_url = user.photo.dup.to_s
      photo_array = photo_url.split('upload/')
      photo = "http://res.cloudinary.com/drinkboard/image/upload/c_fill,h_#{height},w_#{width}/#{photo_array[1]}"      
    end 
    image_tag(photo, alt: "customImageTag", :class => 'gravatar' )
  end

  def large_photo(user)
    image_tag(user.photo_url(:large), :width => 400, :height => 400, :id => "cropbox")
  end

  def preview_large_photo(user)
    image_tag(user.photo_url(:large), :width => 400, :height => 400, :id => "preview")
  end
   
end
