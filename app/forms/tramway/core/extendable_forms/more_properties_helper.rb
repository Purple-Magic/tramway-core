module Tramway::Core::ExtendableForms::MorePropertiesHelper
  def define_property_method(property_name)
    define_method property_name do
      model.values[property_name] if model.values
    end
  end
end
