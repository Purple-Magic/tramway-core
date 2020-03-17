# frozen_string_literal: true

require 'tramway/core/engine'
require 'tramway/collection'
require 'tramway/collections/helper'
require 'tramway/error'
require 'font_awesome5_rails'
require 'reform'
require 'pg_search'
require 'validators/presence_validator'

module Tramway
  module Core
    class << self
      def initialize_application(**options)
        @application ||= Tramway::Core::Application.new
        options.each do |attr, value|
          @application.send "#{attr}=", value
        end
      end

      def application_object
        if @application&.model_class.present?
          begin
            @application.model_class.first
          rescue StandardError
            nil
          end
        else
          @application
        end
      end

      attr_reader :application
    end
  end
end

# HACK: FIXME

module ActiveModel
  class Errors
    def merge!(*args); end
  end
end
