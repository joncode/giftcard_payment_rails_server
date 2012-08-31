module UsersHelper
  
  def gravatar_for(user)
    if user.photo.blank?
      gravatar_url = "ninja_ghost_128.png"
    else
      gravatar_url =  user.photo_url.to_s
    end 
    image_tag(gravatar_url, alt: user.phone, class: "gravatar") 
  end 
  
  def list_icon_for(user)
    if user.photo.blank?
      gravatar_url = "ninja_ghost_128.png"
    else
      gravatar_url =  user.photo_url.to_s
    end 
    image_tag(gravatar_url, alt: user.phone, class: "iconListView")     
  end
  
  def list_icon_with_id_for(user_id)
    if user_id.nil? 
      user = User.new
    else
      user = User.find(user_id)
    end
    if user.photo.blank?
      gravatar_url = "ninja_ghost_128.png"
    else
      gravatar_url =  user.photo_url.to_s
    end 
    image_tag(gravatar_url, alt: user.phone, class: "iconListView")     
  end
   
end
