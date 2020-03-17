# frozen_string_literal: true

module Tramway::Core::Concerns::AttributesDecoratorHelper
  def date_view(value)
    I18n.l value.to_date if value
  end

  def datetime_view(value)
    I18n.l value if value
  end

  def state_machine_view(object, attribute_name)
    object.send "human_#{attribute_name}_name"
  end

  def image_view(original, thumb: nil, filename: nil)
    if original.present?
      thumb ||= original.is_a?(CarrierWave::Uploader::Base) ? original.small : nil
      filename ||= original.is_a?(CarrierWave::Uploader::Base) ? original.path&.split('/')&.last : nil
      src_thumb = if thumb&.is_a?(CarrierWave::Uploader::Base)
                    thumb.url
                  elsif thumb&.match(%r{^(?:[a-zA-Z0-9+/]{4})*(?:|(?:[a-zA-Z0-9+/]{3}=)|(?:[a-zA-Z0-9+/]{2}==)|(?:[a-zA-Z0-9+/]{1}===))$})
                    "data:image/jpeg;base64,#{thumb}"
                  else
                    thumb
                  end
      src_original = if original.is_a?(CarrierWave::Uploader::Base)
                       original.url
                     elsif original.match(%r{^(?:[a-zA-Z0-9+/]{4})*(?:|(?:[a-zA-Z0-9+/]{3}=)|(?:[a-zA-Z0-9+/]{2}==)|(?:[a-zA-Z0-9+/]{1}===))$})
                       "data:image/jpeg;base64,#{original}"
                     else
                       original
                     end
      content_tag(:div) do
        begin
          concat image_tag src_thumb || src_original
        rescue NoMethodError => e
          error = Tramway::Error.new plugin: :core, method: :image_view, message: "You should mount PhotoUploader to your model. Just add `mount_uploader \#{attribute_name}, PhotoUploader` to your model. #{e.message}"
          raise error.message
        end
        concat link_to(fa_icon(:download), src_original, class: 'btn btn-success', download: filename) if filename
      end
    end
  end

  def enumerize_view(value)
    value.text
  end
end
