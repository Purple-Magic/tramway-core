# frozen_string_literal: true

require 'carrierwave'

class ApplicationUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    model.reload if model.respond_to?(:uuid) && !model.uuid.present?
    "system/uploads/#{model.class.model_name.to_s.underscore}/#{mounted_as}/#{model.try(:uuid) || model.id}"
  end
end
