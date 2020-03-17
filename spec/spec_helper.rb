# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('dummy/config/environment', __dir__)
require 'pry'

def bad_ass_monkey_patching_methods(source:)
  methods = {
    active_support: %i[
      debug_missing_translation=
      debug_missing_translation
    ],
    action_view: {
      helpers: %i[
        sanitized_protocol_separator
        sanitized_protocol_separator=
        sanitized_uri_attributes
        sanitized_uri_attributes=
        sanitized_bad_tags
        sanitized_bad_tags=
        sanitized_allowed_css_properties
        sanitized_allowed_css_properties=
        sanitized_allowed_css_keywords
        sanitized_allowed_css_keywords=
        sanitized_shorthand_css_properties
        sanitized_shorthand_css_properties=
        sanitized_allowed_protocols
        sanitized_allowed_protocols=
        full_sanitizer=
        link_sanitizer=
        white_list_sanitizer=
        full_sanitizer
        link_sanitizer
        sanitizer_vendor
        sanitized_allowed_tags
        white_list_sanitizer
        sanitized_allowed_attributes
        sanitized_allowed_tags=
        sanitized_allowed_attributes=
        safe_list_sanitizer
        safe_list_sanitizer=
        _url_for_modules
      ]
    }
  }
  source = [source] unless source.is_a? Array
  methods.dig(*source)
end
