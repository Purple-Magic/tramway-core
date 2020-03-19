# frozen_string_literal: true

class Tramway::Core::ApplicationController < ActionController::Base
  before_action :application
  before_action :load_extensions

  def application
    @application = ::Tramway::Core.application_object
  end

  def load_extensions
    ::Tramway::Extensions.load if defined? ::Tramway::Extensions
  end
end
