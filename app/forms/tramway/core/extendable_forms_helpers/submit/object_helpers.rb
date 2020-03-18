# frozen_string_literal: true

module Tramway::Core::ExtendableFormsHelpers::Submit::ObjectHelpers
  def extended(simple_properties, more_properties, params)
    params.except(*simple_properties.keys).except(*jsonb_ignored_properties(more_properties)).permit!.to_h
  end
end
