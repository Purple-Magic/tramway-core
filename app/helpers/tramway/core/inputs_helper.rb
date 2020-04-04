# frozen_string_literal: true

module Tramway::Core::InputsHelper
  def association_params(form_object:, property:, value:, object:, options: {})
    full_class_name_association = form_object.class.full_class_name_association(property)
    unless full_class_name_association
      raise "It seems you've defined association attributes with `property` method. Please, use `association` method. `association :#{property}`"
    end
    if full_class_name_association.is_a? Array
      raise "It seems you've used `association` input type in the Form. Please, use `polymorphic_association` type. `#{property}: :polymorphic_association`"
    end

    {
      label: false,
      input_html: {
        name: "#{object}[#{property}]",
        id: "#{object}_#{property}",
        value: (form_object.send(property) || form_object.model.send("#{property}_id") || value)
      },
      selected: (form_object.model.send("#{property}_id") || value),
      collection: full_class_name_association.active.send("#{current_user.role}_scope", current_user.id).map do |obj|
        decorator_class(full_class_name_association).decorate obj
      end.sort_by(&:name)
    }.merge options
  end

  def polymorphic_association_params(object:, form_object:, property:, value:, options: {})
    full_class_names = form_object.model.class.send("#{property}_type").values.map &:constantize
    collection = full_class_names.map do |class_name|
      class_name.active.send("#{current_user.role}_scope", current_user.id).map do |obj|
        decorator_class(class_name).decorate obj
      end
    end.flatten.sort_by { |obj| obj.name.to_s }
    builded_value = if form_object.send(property).present?
                      "#{form_object.send(property).class.to_s.underscore}_#{form_object.send(property).id}"
                    else
                      "#{value[:type]&.underscore}_#{value[:id]}"
                    end
    {
      as: :select,
      label: false,
      input_html: {
        name: "#{object}[#{property}]",
        id: "#{object}_#{property}",
        value: builded_value
      },
      selected: builded_value,
      collection: collection,
      label_method: lambda do |obj|
        "#{obj.class.model_name.human} | #{obj.name}"
      end,
      value_method: lambda do |obj|
        "#{obj.class.to_s.underscore.sub(/_decorator$/, '')}_#{obj.id}"
      end
    }.merge options
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

  def else_params(property:, object:, type:, form_object:, value:, options: {})
    {
      as: type,
      label: false,
      input_html: {
        name: "#{object}[#{property}]",
        id: "#{object}_#{property}",
        value: (form_object.send(property) || form_object.model.send(property) || value)
      }
    }.merge options
  end
end
