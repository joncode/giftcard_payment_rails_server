module ApplicationHelper
  
  def merchant_tag(user)
    if (user.provider_id.nil?) || (user.provider_id == "0")
      link_to "Merchant Sign Up", new_provider_path
    else
      link_to "Merchant Sign In", merchants_path
    end
  end
  
  def download_img_url_for(photo)
    if !photo.nil?
      AWS::S3::S3Object.url_for(photo, PORTRAIT, :authenticated => false)
    end
  end
end
