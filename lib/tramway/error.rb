# frozen_string_literal: true

class Tramway::Error < RuntimeError
  def initialize(*args, plugin: nil, method: nil, message: nil)
    @properties ||= {}
    @properties[:plugin] = plugin
    @properties[:method] = method
    @properties[:message] = message
    super(*args)
  end

  def message
    "Plugin: #{@properties[:plugin]}; Method: #{@properties[:method]}; Message: #{@properties[:message]}"
  end

  def properties
    @properties ||= {}
  end
end
