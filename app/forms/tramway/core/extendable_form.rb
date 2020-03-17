# frozen_string_literal: true

class Tramway::Core::ExtendableForm
  class << self
    def new(name, simple_properties: {}, **more_properties)
      if Object.const_defined? name
        name.constantize
      else
        Object.const_set(name, Class.new(::Tramway::Core::ApplicationForm) do
          properties(*simple_properties.keys) if simple_properties.keys.any?

          define_method 'submit' do |params|
            model.values ||= {}
            extended_params = params.except(*simple_properties.keys).except(*jsonb_ignored_properties(more_properties))
            params.each do |key, value|
              method_name = "#{key}="
              send method_name, value if respond_to?(method_name)
            end
            model.values = extended_params.permit!.to_h.reduce(model.values) do |hash, pair|
              hash.merge! pair[0] => pair[1]
            end
            super(params) && model.errors.empty?
          end

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
                file_instance = property[1][:association_model].find_or_create_by "#{model.class.name.underscore}_id" => model.id, "#{field.class.name.underscore}_id" => field.id
                file_instance.file = value
                file_instance.save!
              end
            else
              next unless property[1][:validates].present?

              define_method "#{property[0]}=" do |value|
                property[1][:validates].each do |pair|
                  case pair[0].to_s
                  when 'presence'
                    validator_object = "#{pair[0].to_s.camelize}Validator".constantize.new(attributes: :not_blank)
                    if pair[1] == 'true' && !validator_object.send(:valid?, value)
                      model.errors.add property[0],
                        I18n.t("activerecord.errors.models.#{model.class.name.underscore}.attributes.default.#{pair[0]}", value: value)
                    end
                  when 'inclusion'
                    in_array = pair[1][:in]
                    unless value.in? in_array
                      model.errors.add property[0],
                        I18n.t("activerecord.errors.models.#{model.class.name.underscore}.attributes.default.#{pair[0]}", value: value)
                    end
                  end
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
