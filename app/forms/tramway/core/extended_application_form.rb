# frozen_string_literal: true

class Tramway::Core::ExtendedApplicationForm < Tramway::Core::ApplicationForm
  class << self
    def properties(*args)
      @extendable_properties ||= [] # here maybe @@extendable_properties
      @extendable_properties += args # here maybe @@extendable_properties
      super(*args)
    end
  end

  def initialize(model)
    @extendable_properties.each do |prop| # here maybe @@extendable_properties
      next if model.respond_to? prop

      model.class.define_method prop do
      end
      model.class.define_method "#{prop}=" do |value|
      end
    end
    super
  end
end
