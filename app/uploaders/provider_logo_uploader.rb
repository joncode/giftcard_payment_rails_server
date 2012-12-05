class ProviderLogoUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  process :convert => 'jpg'
  process :resize_to_limit => [350,500]
  process :initial_crop
  process :resize_to_fill => [60,60]
  
  def initial_crop
    return :x => model.crop_x, :y => model.crop_y, :width => model.crop_w, :height => model.crop_h
  end
end