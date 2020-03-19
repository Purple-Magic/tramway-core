# frozen_string_literal: true

module Tramway::Core::Associations::ObjectHelper
  def class_name(association)
    if association.polymorphic?
      object.send(association.name).class
    else
      unless association.options[:class_name]
        Tramway::Error.raise_error(
          :tramway, :core, :associations, :object_helper, :please_specify_association_name,
          association_name: association.name, object_class: object.class,
          association_class_name: association.name.to_s.singularize.camelize
        )
      end
      association.options[:class_name]
    end
  end
end
