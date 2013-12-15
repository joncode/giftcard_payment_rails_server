class ProviderLogoUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  process :convert => 'jpg'
  process :initial_crop
    
  def initial_crop
    return { :transformation => 
      [{:width => 350, :height => 500, :crop => :limit}, 
      {:x => model.crop_x, :y => model.crop_y, :width => model.crop_w, :height => model.crop_h, :crop => :crop}]
    }
  end
end