# frozen_string_literal: true

class FileUploader < ApplicationUploader
  def extension_white_list
    %w[pdf doc docx xls csv xlsx jpg svg png jpeg gif]
  end
end
