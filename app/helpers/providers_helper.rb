module ProvidersHelper
  
  def logo_for(provider)
    if provider.logo.blank?
      gravatar_url = "biz_logo.png"
    else
      gravatar_url =  provider.logo.to_s
    end 
    image_tag(gravatar_url, alt: provider.name, class: "iconListView") 
  end
  
  def logo_from_id_for(provider_id)
    if provider_id.nil? 
      provider = Provider.new
    else
      provider = Provider.find(provider_id)
    end
    if provider.logo.blank?
      gravatar_url = "biz_logo.png"
    else
      gravatar_url =  provider.logo.to_s
    end 
    image_tag(gravatar_url, alt: provider.name, class: "iconListView") 
  end

end
