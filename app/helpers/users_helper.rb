module UsersHelper
  
  def gravatar_for(user)
    if user.photo.blank?
      gravatar_url = "ninja_ghost_128.png"
    else
      #gravatar_url =  download_img_url_for(user.photo.to_s)
      gravatar_url =  download_img_url_for("13.png")
    end 
    image_tag(gravatar_url, alt: "cant locate image", class: "gravatar") 
  end 
  
  def list_icon_for(user)
    if user.photo.blank?
      gravatar_url = "ninja_ghost_128.png"
    else
      #gravatar_url =  download_img_url_for(user.photo.to_s)
      gravatar_url =  download_img_url_for("13.png")
    end 
    image_tag(gravatar_url, alt: "cant locate image", class: "iconListView")     
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
      #gravatar_url =  download_img_url_for(user.photo.to_s)
      gravatar_url =  download_img_url_for("13.png")
    end 
    image_tag(gravatar_url, alt: "cant locate image", class: "iconListView")     
  end
   
end
