# frozen_string_literal: true

class Tramway::Core::ExtendableForm
  class << self

    def new(name, simple_properties: {}, **more_properties)
      if Object.const_defined? name
        name.constantize
      else
        Object.const_set(name, Class.new(::Tramway::Core::ApplicationForm) do
          properties(*simple_properties.keys) if simple_properties.keys.any?
          
          extend Tramway::Core::ExtendableForms::SubmitHelpers
          include Tramway::Core::ExtendableForms::Validators

          define_submit_method simple_properties, more_properties

          define_method 'properties' do
            hash = simple_properties.each_with_object({}) do |property, h|
              h.merge! property[0] => property[1] unless model.class.state_machines.keys.include?(property[0])
            end
            more_properties.reduce(hash) do |h, property|
              h.merge! property[0] => {
                extended_form_property: property[1][:object]
              }
            end
          end

          more_properties.each do |property|
            define_method property[0] do
              model.values[property[0]] if model.values
            end

            case property[1][:object].field_type
            when 'file'
              field = property[1][:object]
              define_method "#{property[0]}=" do |value|
                file_instance = property[1][:association_model].find_or_create_by(
                  "#{model.class.name.underscore}_id" => model.id, "#{field.class.name.underscore}_id" => field.id
                )
                file_instance.file = value
                file_instance.save!
              end
            else
              next unless property[1][:validates].present?

              define_method "#{property[0]}=" do |value|
                property[1][:validates].each do |pair|
                  make_validates property[0], pair, value
                end
              end
            end
          end

          define_method :jsonb_ignored_properties do |properties|
            properties.map do |property|
              property[0].to_s if property[1][:object].field_type == 'file'
            end.compact
          end
        end)
      end
    end
  end
end
