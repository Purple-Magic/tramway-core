# frozen_string_literal: true

module Tramway::Core::InputsHelper
  include Tramway::Core::Inputs::AssociationsHelper
  include Tramway::Core::Inputs::PolymorphicAssociationsHelper

  def association_params(form_object:, property:, value:, object:, options: {})
    build_input_attributes(object: object, property: property, options: options,
                           value: build_value_for_association(form_object, property, value),
                           collection: build_collection_for_association(form_object, property),
                           selected: form_object.model.send("#{property}_id") || value)
  end

  def polymorphic_association_params(object:, form_object:, property:, value:, options: {})
    build_input_attributes object: object, property: property,
                           selected: build_value_for_polymorphic_association(form_object, property, value),
                           value: build_value_for_polymorphic_association(form_object, property, value),
                           collection: build_collection_for_polymorphic_association(form_object, property),
                           options: options.merge(
                             as: :select,
                             label_method: ->(obj) { "#{obj.class.model_name.human} | #{obj.name}" },
                             value_method: lambda do |obj|
                               "#{obj.class.to_s.underscore.sub(/_decorator$/, '')}_#{obj.id}"
                             end
                           )
  end

  def build_input_attributes(**options)
    {
      label: false,
      input_html: {
        name: "#{options[:object]}[#{options[:property]}]",
        id: "#{options[:object]}_#{options[:property]}",
        value: options[:value]
      },
      selected: options[:selected],
      collection: options[:collection]
    }.merge options[:options]
  end

  def value_from_params(model_class:, property:, type:)
    case type
    when :polymorphic_association, 'polymorphic_association'
      {
        id: params.dig(model_class.to_s.underscore, property.to_s),
        type: params.dig(model_class.to_s.underscore, "#{property}_type")
      }
    else
      params.dig(model_class.to_s.underscore, property.to_s)
    end
  end

  def default_params(property:, object:, form_object:, value:, options: {})
    {
      label: false,
      input_html: {
        name: "#{object}[#{property}]",
        id: "#{object}_#{property}",
        value: (form_object.send(property) || form_object.model.send(property) || value)
      },
      selected: (form_object.model.send(property) || value)
    }.merge options
  end

  def else_params(**options)
    {
      as: options[:type],
      label: false,
      input_html: {
        name: "#{options[:object]}[#{options[:property]}]",
        id: "#{options[:object]}_#{options[:property]}",
        value: build_else_value(options[:form_object], options[:property], options[:value])
      }
    }.merge options[:options] || {}
  end

  def build_else_value(form_object, property, value)
    form_object.send(property) ? form_object.model.send(property) : value
  end
end
