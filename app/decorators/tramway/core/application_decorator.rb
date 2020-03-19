# frozen_string_literal: true

require 'tramway/error'

class Tramway::Core::ApplicationDecorator
  include ActionView::Helpers
  include ActionView::Context
  include ::FontAwesome5::Rails::IconHelper
  include ::Tramway::Core::CopyToClipboardHelper
  include ::Tramway::Core::Associations::ObjectHelper
  include ::Tramway::Core::Attributes::ViewHelper

  def initialize(object)
    @object = object
  end

  def name
    object.try(:name) || object.try(:title) || title
  end

  def title
    Tramway::Error.raise_error(
      :tramway, :core, :application_decorator, :title, :please_implement_title,
      class_name: self.class, object_class: object.class
    )
  end

  delegate :id, to: :object
  delegate :human_state_name, to: :object

  class << self
    include ::Tramway::Core::Associations::ClassHelper
    include ::Tramway::Core::Delegating::ClassHelper

    def collections
      [:all]
    end

    def list_attributes
      []
    end

    def show_attributes
      []
    end

    def show_associations
      []
    end

    def decorate(object_or_array)
      if object_or_array.class.superclass == ActiveRecord::Relation
        decorated_array = object_or_array.map do |obj|
          new obj
        end
        Tramway::Core::ApplicationDecoratedCollection.new decorated_array, object_or_array
      else
        new object_or_array
      end
    end

    def model_class
      to_s.sub(/Decorator$/, '').constantize
    end

    def model_name
      model_class.try(:model_name)
    end
  end

  def link
    if object.try :file
      object.file.url
    else
      Tramway::Error.raise_error :tramway, :core, :application_decorator, :link, :method_link_uses_file_attribute
    end
  end

  def public_path; end

  def model
    object
  end

  def associations(associations_type)
    object.class.reflect_on_all_associations(associations_type).map do |association|
      association unless association.name == :audits
    end.compact
  end

  include Tramway::Core::Concerns::AttributesDecoratorHelper

  RESERVED_WORDS = ['fields'].freeze

  def attributes
    object.attributes.reduce({}) do |hash, attribute|
      if attribute[0].in? RESERVED_WORDS
        Tramway::Error.raise_error(
          :tramway, :core, :application_decorator, :attributes, :method_is_reserved_word,
          attribute_name: attribute[0], class_name: self.class.name
        )
      end
      hash.merge! attribute[0] => build_viewable_value(object, attribute)
    end
  end

  def yes_no(boolean_attr)
    boolean_attr.to_s == 'true' ? I18n.t('helpers.yes') : I18n.t('helpers.no')
  end

  protected

  attr_reader :object

  def association_class_name; end
end
