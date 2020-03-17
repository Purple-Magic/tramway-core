# frozen_string_literal: true

module Tramway
  module Collections
    module Helper
      def collection_list_by(name:)
        begin
          require name # needed to load class name with collection
        rescue LoadError
          raise "No such file #{name}. You should create file in the `lib/#{name}.rb` or elsewhere you want"
        end
        unless ::Tramway::Collection.descendants.map(&:to_s).include?(name.camelize)
          raise "There no such collection named #{name.camelize}. Please create class with self method `list` and extended of `Tramway::Collection`. You should reload your server after creating this collection."
        end

        name.camelize.constantize.list
      end
    end
  end
end
