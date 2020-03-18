module Tramway::Core::ExtendableForms::MorePropertiesHelper
  def define_property_method(property_name)
    define_method property_name do
      model.values[property_name] if model.values
    end
  end

  def define_file_property_assigment_method(property_name, field)
    define_method "#{property[0]}=" do |value|
      file_instance = property[1][:association_model].find_or_create_by(
        "#{model.class.name.underscore}_id" => model.id, "#{field.class.name.underscore}_id" => field.id
      )
      file_instance.file = value
      file_instance.save!
    end
  end
end
