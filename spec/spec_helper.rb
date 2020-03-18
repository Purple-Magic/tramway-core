# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('dummy/config/environment', __dir__)
require 'pry'

def bad_ass_monkey_patching_methods(source:)
  methods = symbolize_values(YAML.load_file(Rails.root.join('..', 'yaml', 'methods.yml')).deep_symbolize_keys[:methods])
  source = [source] unless source.is_a? Array
  methods.dig(*source)
end

def symbolize_values(hash)
  hash.reduce({}) do |new_hash, pair|
    case pair[1].class.to_s
    when 'String'
      new_hash.merge! pair[0] => pair[1].to_sym
    when 'Hash'
      new_hash.merge! pair[0] => symbolize_values(pair[1])
    when 'Array'
      new_hash.merge! pair[0] => pair[1].map(&:to_sym)
    else
      new_hash.merge! pair[0] => pair[1]
    end
  end
end
