# frozen_string_literal: true

module Tramway::Core::ExtendableForms::SubmitHelpers
  def define_submit_method(simple_properties, more_properties, model)
    define_method 'submit' do |params|
      model.values ||= {}
      extended_params = extended(params, simple_properties, more_properties).permit!.to_h
      call_all_attributes_by params
      model.values = extended_params.reduce(model.values) do |hash, pair|
        hash.merge! pair[0] => pair[1]
      end
      super(params) && model.errors.empty?
    end
  end

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
