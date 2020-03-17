# frozen_string_literal: true

module Tramway::Core
  class ApplicationForm < ::Reform::Form
    def initialize(object = nil)
      object ||= self.class.model_class.new
      super(object).tap do
        @@model_class = object.class
        @@enumerized_attributes = object.class.try :enumerized_attributes
        @@associations ||= []

        self.class.full_class_name_associations.each do |association, class_name|
          if class_name.is_a? Array
            self.class.send(:define_method, "#{association}=") do |value|
              association_class = value.split('_')[0..-2].join('_').camelize
              association_class = association_class.constantize if association_class.is_a? String
              if association_class.nil?
                raise Tramway::Error.new(plugin: :core, method: :initialize, message: 'Polymorphic association class is nil. Maybe, you should write `assocation #{association_name}` after `properties #{association_name}_id, #{association_name}_type`')
              else
                super association_class.find value.split('_')[-1]
                send "#{association}_type=", association_class.to_s
              end
            end
          else
            self.class.send(:define_method, "#{association}=") do |value|
              super class_name.find value
            end
          end
        end

        delegating object
      end
    end

    def submit(params)
      if params
        if validate params
          begin
            save
          rescue StandardError => e
            error = Tramway::Error.new(plugin: :core, method: :submit, message: "Looks like you have method `#{e.name.to_s.gsub('=', '')}` in #{@@model_class}. You should rename it or rename property in #{self.class}")
            raise error.message
          end
        else
          @@associations.each do |association|
            if errors.details[association] == [{ error: :blank }]
              model.send("#{association}=", send(association))
            end
          end
        end
      else
        error = Tramway::Error.new(plugin: :core, method: :submit, message: 'ApplicationForm::Params should not be nil')
        raise error.message
      end
    end

    def model_name
      @@model_class.model_name
    end

    def associations
      @@associations
    end

    def form_properties(**args)
      @form_properties = args
    end

    def form_properties_additional(**args)
      @form_properties_additional = args
    end

    def properties
      return @form_properties if @form_properties

      yaml_config_file_path = Rails.root.join('app', 'forms', "#{self.class.name.underscore}.yml")
      if File.exist? yaml_config_file_path
        @form_properties = YAML.load_file(yaml_config_file_path).deep_symbolize_keys
        @form_properties.deep_merge! @form_properties_additional if @form_properties_additional
        @form_properties
      else
        []
      end
    end

    def build_errors; end

    def delegating(object)
      methods = %i[to_key errors]
      methods.each do |method|
        self.class.send(:define_method, method) do
          object.send method
        end
      end
    end

    def attributes
      properties.reduce({}) do |hash, property|
        hash.merge! property.first => model.values[property.first.to_s]
      end
    end

    class << self
      delegate :defined_enums, to: :model_class

      def association(property)
        properties property
        @@associations ||= []
        @@associations << property
      end

      def associations(*properties)
        properties.each do |property|
          association property
        end
      end

      def full_class_name_associations
        @@associations&.reduce({}) do |hash, association|
          options = @@model_class.reflect_on_all_associations(:belongs_to).select do |a|
            a.name == association.to_sym
          end.first&.options

          if options
            if options[:polymorphic]
              hash.merge! association => @@model_class.send("#{association}_type").values
            else
              class_name = options[:class_name] || association.to_s.camelize
              hash.merge!(association => class_name.constantize)
            end
          end
          hash
        end
      end

      def full_class_name_association(association_name)
        full_class_name_associations[association_name]
      end

      def enumerized_attributes
        @@enumerized_attributes
      end

      def reflect_on_association(*args)
        @@model_class.reflect_on_association(*args)
      end

      def model_class
        if defined?(@@model_class) && @@model_class
          @@model_class
        else
          model_class_name ||= name.to_s.sub(/Form$/, '')
          begin
            @@model_class = model_class_name.constantize
          rescue StandardError
            error = Tramway::Error.new(plugin: :core, method: :model_class, message: "There is not model class name for #{name}. Should be #{model_class_name} or you can use another class to initialize form object or just initialize form with object.")
            raise error.message
          end
        end
      end

      def model_class=(name)
        @@model_class = name
      end

      def validation_group_class
        ActiveModel
      end

      def validates(attribute, **options)
        if !defined?(@@model_class) || @@model_class.nil?
          error = Tramway::Error.new(plugin: :core, method: :validates, message: 'You need to set `model_class` name while using validations. Just write `self.model_class = YOUR_MODEL_NAME` in the class area.')
          raise error.message
        end
        @@model_class.validates attribute, **options
      end
    end
  end
end
