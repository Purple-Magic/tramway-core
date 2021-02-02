# frozen_string_literal: true

require 'carrierwave/orm/activerecord' if defined?(CarrierWave::Mount)

class Tramway::Core::ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  audited
  extend ::Enumerize
  include ::AASM

  aasm column: :state do
    state :active, initial: true
    state :removed

    event :remove do
      transitions from: :active, to: :removed
    end
  end

  scope :active, -> { where state: :active }
  scope :created_by_user, lambda { |user_id|
    joins(:audits).where('audits.action = \'create\' AND audits.user_id = ?', user_id)
  }
  scope :admin_scope, -> (_arg) { all }

  include ::PgSearch::Model

  def creator
    creation_event = audits.where(action: :create).first
    creation_event.user if creation_event.user_id.present?
  end

  # FIXME: detect inhertited locales
  class << self
    def human_attribute_name(attribute_name, *_args)
      excepted_attributes = %w[created_at updated_at state]
      if attribute_name.to_s.in? excepted_attributes
        I18n.t "activerecord.attributes.tramway/core/application_record.#{attribute_name}"
      else
        super attribute_name
      end
    end

    def search_by(*attributes, **associations)
      pg_search_scope :full_text_search, against: attributes, associated_against: associations
    end

    def uploader(attribute_name, uploader_name, **options)
      mount_uploader attribute_name, "#{uploader_name.to_s.camelize}Uploader".constantize
      @versions = options[:versions] if uploader_name == :photo
      @extensions = options[:extensions]
    end

    def photo_versions
      @versions
    end

    def file_extensions
      @extensions
    end
  end

  # FIXME: detect inhertited locales
  def human_state_name
    I18n.t "activerecord.state_machines.tramway/core/application_record.state.states.#{state}"
  end
end
