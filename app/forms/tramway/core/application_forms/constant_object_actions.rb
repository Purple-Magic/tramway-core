# frozen_string_literal: true

module Tramway::Core::ApplicationForms::ConstantObjectActions
  def delegating(object)
    %i[to_key errors].each { |method| self.class.send(:define_method, method) { object.send method } }
  end

  def build_errors; end

  def attributes
    properties.reduce({}) { |hash, property| hash.merge! property.first => model.values[property.first.to_s] }
  end
end
