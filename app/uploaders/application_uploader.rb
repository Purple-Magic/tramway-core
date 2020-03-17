# frozen_string_literal: true

require 'carrierwave'

class ApplicationUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "system/uploads/#{model.class.model_name.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
