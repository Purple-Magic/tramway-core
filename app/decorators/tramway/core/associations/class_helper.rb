# frozen_string_literal: true

module Tramway::Core::Associations::ClassHelper
  def decorate_association(association_name, decorator: nil, as: nil, state_machines: [])
    @@decorated_associations ||= []
    @@decorated_associations << association_name

    define_main_association_method association_name, decorator

    define_method "#{association_name}_as" do
      as
    end

    define_method "#{association_name}_state_machines" do
      state_machines
    end

    define_method "add_#{association_name}_form" do
      "Admin::#{object.class.to_s.pluralize}::Add#{association_name.to_s.camelize.singularize}Form".constantize.new object
    end
  end

  def decorate_associations(*association_names)
    association_names.each do |association_name|
      decorate_association association_name
    end
  end
  def define_main_association_method(association_name, decorator)
    define_method association_name do
      association = object.class.reflect_on_association(association_name)
      if association.nil?
        error = Tramway::Error.new(plugin: :core, method: :decorate_association, message: "Model #{object.class} does not have association named `#{association_name}`")
        raise error.message
      end
      decorator_class_name = decorator || "#{class_name(association).to_s.singularize}Decorator".constantize
      if association.class.in? [ActiveRecord::Reflection::HasManyReflection, ActiveRecord::Reflection::HasAndBelongsToManyReflection]
        return object.send(association_name).active.map do |association_object|
          decorator_class_name.decorate association_object
        end
      end
      if association.class == ActiveRecord::Reflection::BelongsToReflection
        return decorator_class_name.decorate object.send association_name
      end
    end
  end
end
