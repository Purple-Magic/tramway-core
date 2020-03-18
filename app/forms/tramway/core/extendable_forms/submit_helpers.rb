# frozen_string_literal: true

module Tramway::Core::ExtendableForms::SubmitHelpers
  def call_all_attributes_by(params)
    params.each do |key, value|
      method_name = "#{key}="
      send method_name, value if respond_to?(method_name)
    end
  end

  def extended(params, simple_properties, more_properties)
    params.except(*simple_properties.keys).except(*jsonb_ignored_properties(more_properties))
  end
end
