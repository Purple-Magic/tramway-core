# frozen_string_literal: true

require 'rails/generators'

module Tramway
  module Core
    module Generators
      class InstallGenerator < ::Rails::Generators::Base
        source_root File.expand_path('templates', __dir__)

        def run_other_generators
          generate 'audited:install'
        end

        def self.next_migration_number(path)
          next_migration_number = current_migration_number(path) + 1
          ActiveRecord::Migration.next_migration_number next_migration_number
        end

        def copy_initializer
          copy_file "/#{File.dirname __dir__}/generators/templates/initializers/simple_form.rb", 'config/initializers/simple_form.rb'
          copy_file "/#{File.dirname __dir__}/generators/templates/initializers/simple_form_bootstrap.rb", 'config/initializers/simple_form_bootstrap.rb'
        end
      end
    end
  end
end
