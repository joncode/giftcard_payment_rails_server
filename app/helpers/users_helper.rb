module UsersHelper
  
  def gravatar_for(user)
    if user.photo.blank?
      gravatar_url = "ninja_ghost_128.png"
      image_tag(gravatar_url, alt: "#{user.username}", class: "gravatar")
    else
      image_tag(user.photo_url(:thumbnail), :width => 75, :height => 100)
    end   
  end
  
  def list_icon_for(user)
    if user.photo.blank?
      gravatar_url = "ninja_ghost_128.png"
      image_tag(gravatar_url, alt: "#{user.username}", class: "gravatar")
    else
      image_tag(user.photo_url(:thumbnail), :width => 50, :height => 50)
    end   
  end
  
  def list_icon_with_id_for(user_id)
    if user_id.nil? 
      user = User.new
    else
      user = User.find(user_id)
    end
    if user.photo.blank?
      gravatar_url = "ninja_ghost_128.png"
      image_tag(gravatar_url, alt: "#{user.username}", class: "gravatar")
    else
      image_tag(user.photo_url(:thumbnail), :width => 50, :height => 50)
    end   
  end
   
end
