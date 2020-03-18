# frozen_string_literal: true

class Tramway::Core::ExtendableForm
  class << self
    def new(name, simple_properties: {}, **more_properties)
      if Object.const_defined? name
        name.constantize
      else
        Object.const_set(name, Class.new(::Tramway::Core::ApplicationForm) do
          properties(*simple_properties.keys) if simple_properties.keys.any?

          extend Tramway::Core::ExtendableForms::Submit::ClassHelpers
          include Tramway::Core::ExtendableForms::Submit::ObjectHelpers
          include Tramway::Core::ExtendableForms::Validators
          extend Tramway::Core::ExtendableForms::PropertiesHelper
          extend Tramway::Core::ExtendableForms::MorePropertiesHelper
          extend Tramway::Core::ExtendableForms::IgnoredPropertiesHelper

          define_submit_method simple_properties, more_properties
          define_properties_method simple_properties, more_properties

          more_properties.each do |property|
            define_property_method property[0]

            case property[1][:object].field_type
            when 'file'
              field = property[1][:object]
              define_file_property_assignment_method property field
            else
              next unless property[1][:validates].present?

              define_assignment_method property
            end
          end
          define_ignored_properties_method
        end)
      end
    end
  end
end
