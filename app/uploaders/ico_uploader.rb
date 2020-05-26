# frozen_string_literal: true

class IcoUploader < ApplicationUploader
  def extension_whitelist
    model.class.file_extensions || %w[ico]
  end
end
