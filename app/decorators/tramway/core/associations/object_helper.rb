# frozen_string_literal: true

module Tramway::Core::Associations::ObjectHelper
  def class_name(association)
    if association.polymorphic?
      object.send(association.name).class
    else
      unless association.options[:class_name]
        error = Tramway::Error.new(plugin: :core, method: :decorate_association, message: "Please, specify `#{association_name}` association class_name in #{object.class} model. For example: `has_many :#{association_name}, class_name: '#{association_name.to_s.singularize.camelize}'`")
        raise error.message
      end
      association.options[:class_name]
    end
  end
end
