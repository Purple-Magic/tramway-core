# frozen_string_literal: true

require 'carrierwave'

class ApplicationUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    directory_id = (model.reload && model.try(:uuid)) || model.id
    "system/uploads/#{model.class.model_name.to_s.underscore}/#{mounted_as}/#{directory_id}"
  end
end
