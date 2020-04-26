# frozen_string_literal: true

module Tramway::Core::ExtendableFormsHelpers::Submit::ClassHelpers
  def define_submit_method(simple_properties, more_properties)
    define_method 'submit' do |params|
      model.values ||= {}
      extended_params = extended(simple_properties, more_properties, params)
      params.each do |key, value|
        method_name = "#{key}="
        send method_name, value if respond_to?(method_name)
      end
      model.values = extended_params.reduce(model.values) do |hash, pair|
        hash.merge! pair[0] => pair[1]
      end

      return unless model.errors.empty?

      params.each { |key, value| send("#{key}=", value) }
      result = save
      result.tap do
        collecting_associations_errors unless result
      end
    end
  end
end
