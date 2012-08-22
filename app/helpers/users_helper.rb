module UsersHelper
  
  def gravatar_for(user)
    if user.photo.blank?
      gravatar_url = "ninja_ghost_128.png"
    else
      gravatar_url =  user.photo.to_s
    end 
    image_tag(gravatar_url, alt: user.phone, class: "gravatar") 
  end 
  
  def list_icon_for(user)
    if user.photo.blank?
      gravatar_url = "ninja_ghost_128.png"
    else
      gravatar_url =  user.photo.to_s
    end 
    image_tag(gravatar_url, alt: user.phone, class: "iconListView")     
  end
   
end
