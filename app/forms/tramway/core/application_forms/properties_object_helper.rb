# frozen_string_literal: true

module Tramway::Core::ApplicationForms::PropertiesObjectHelper
  def form_properties(**args)
    @form_properties = args
  end

  def form_properties_additional(**args)
    @form_properties_additional = args
  end

  def properties
    return @form_properties if @form_properties

    yaml_config_file_path = Rails.root.join('app', 'forms', "#{self.class.name.underscore}.yml")

    return [] unless File.exist? yaml_config_file_path

    @form_properties = YAML.load_file(yaml_config_file_path).deep_symbolize_keys
    @form_properties.deep_merge! @form_properties_additional if @form_properties_additional
    @form_properties
  end
end
