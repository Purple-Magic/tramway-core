# frozen_string_literal: true

class FileUploader < ApplicationUploader
  def extension_whitelist
    model.class.file_extensions || %w[pdf doc docx xls csv xlsx jpg svg png jpeg gif]
  end
end
