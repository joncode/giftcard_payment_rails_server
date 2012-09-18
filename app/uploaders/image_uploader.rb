# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  process :convert => 'png'
  process :tags => ['post_picture']
  
  version :standard do
    process :resize_to_fill => [100, 150, :north]
  end
  
  version :large do
    process :resize_to_fill => [400, 400]
  end
  
  version :thumbnail do
    process :resize_to_fit => [75, 100]
  end

  def crop
    if model.crop_x.present?
      resize_to_limit(600, 600)
      manipulate! do |img|
        x = model.crop_x.to_i
        y = model.crop_y.to_i
        w = model.crop_w.to_i
        h = model.crop_h.to_i
        img.crop!(x, y, w, h)
      end
    end
  end
  # def public_id
  #   return model.short_name
  # end
end
