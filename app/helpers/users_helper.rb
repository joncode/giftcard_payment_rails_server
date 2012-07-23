module UsersHelper
  
  def gravatar_for(user)
    if user.photo.blank?
      gravatar_url = "blank.png"
    else
      gravatar_url =  user.photo.to_s
    end 
    image_tag(gravatar_url, alt: user.username, class: "gravatar") 
  end 
   
end
