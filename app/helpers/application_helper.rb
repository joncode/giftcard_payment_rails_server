module ApplicationHelper
  
  def merchant_tag(user)
    if user.provider_id.empty?
      link_to "Merchant Sign Up", new_provider_path
    else
      link_to "Merchant Sign In", merchants_path
    end
  end
end
