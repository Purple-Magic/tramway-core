# frozen_string_literal: true

class Tramway::Core::ApplicationForm < ::Reform::Form
  include Tramway::Core::ApplicationForms::AssociationObjectHelpers
  include Tramway::Core::ApplicationForms::ConstantObjectActions
  include Tramway::Core::ApplicationForms::PropertiesObjectHelper

  attr_accessor :submit_message

  def initialize(object = nil)
    object ||= self.class.model_class.new
    super(object).tap do
      @@model_class = object.class
      @@enumerized_attributes = object.class.try :enumerized_attributes
      @@associations ||= []

      self.class.full_class_name_associations&.each do |association, class_name|
        define_association_method association, class_name
      end

      delegating object
    end
  end

  def submit(params)
    if params
      validate(params) ? save : collecting_associations_errors
    else
      Tramway::Error.raise_error(:tramway, :core, :application_form, :submit, :params_should_not_be_nil)
    end
  end

  def model_name
    @@model_class.model_name
  end

  def associations
    @@associations
  end

  def to_model
    self
  end

  def persisted?
    model.id.nil?
  end

  class << self
    include Tramway::Core::ApplicationForms::ConstantClassActions

    delegate :defined_enums, to: :model_class

    def association(property)
      properties property
      @@associations = ((defined?(@@associations) && @@associations) || []) + [property]
    end

    def associations(*properties)
      properties.each { |property| association property }
    end

    def full_class_name_associations
      @@associations&.reduce({}) do |hash, association|
        options = @@model_class.reflect_on_all_associations(:belongs_to).select do |a|
          a.name == association.to_sym
        end.first&.options

        if options&.dig(:polymorphic)
          hash.merge! association => @@model_class.send("#{association}_type").values
        elsif options
          hash.merge!(association => (options[:class_name] || association.to_s.camelize).constantize)
        end
        hash
      end
    end

    def full_class_name_association(association_name)
      full_class_name_associations[association_name]
    end

    def reflect_on_association(*args)
      @@model_class.reflect_on_association(*args)
    end

    def enumerized_attributes
      @@enumerized_attributes
    end

    def model_class
      if defined?(@@model_class) && @@model_class
        @@model_class
      else
        model_class_name ||= name.to_s.sub(/Form$/, '')
        begin
          @@model_class = model_class_name.constantize
        rescue StandardError
          Tramway::Error.raise_error :tramway, :core, :application_form, :model_class, :there_is_not_model_class,
            name: name, model_class_name: model_class_name
        end
      end
    end

    def model_class=(name)
      @@model_class = name
    end

    def validates(attribute, **options)
      if !defined?(@@model_class) || @@model_class.nil?
        Tramway::Error.raise_error(:tramway, :core, :application_form, :validates, :you_need_to_set_model_class)
      end
      @@model_class.validates attribute, **options
    end
  end

  private

  def collecting_associations_errors
    @@associations.each do |association|
      model.send("#{association}=", send(association)) if errors.details[association] == [{ error: :blank }]
    end
  end

  def save
    super
  rescue ArgumentError => e
    Tramway::Error.raise_error :tramway, :core, :application_form, :save, :argument_error, message: e.message
  rescue StandardError => e
    Tramway::Error.raise_error :tramway, :core, :application_form, :save, :looks_like_you_have_method,
      method_name: e.name.to_s.gsub('=', ''), model_class: @@model_class, class_name: self.class
  end
end
