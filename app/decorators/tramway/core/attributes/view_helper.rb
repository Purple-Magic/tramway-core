# frozen_string_literal: true

module Tramway::Core::Attributes::ViewHelper
  def build_viewable_value(object, attribute)
    value = try(attribute[0]) ? send(attribute[0]) : object.send(attribute[0])
    state_machine_view(object, attribute[0]) if is_state_machine? object, attribute[0]

    view_by_value object, value
  end

  def state_machine?(object, attribute_name)
    attribute_name.to_s.in? object.class.state_machines.keys.map(&:to_s)
  end

  def view_by_value(object, value)
    if value.class.in? [ActiveSupport::TimeWithZone, DateTime, Time]
      datetime_view(attribute[1])
    elsif value.class.superclass == ApplicationUploader
      image_view(object.send(attribute[0]))
    elsif value.is_a? Enumerize::Value
      enumerize_view(value)
    else
      value
    end
  end
end
