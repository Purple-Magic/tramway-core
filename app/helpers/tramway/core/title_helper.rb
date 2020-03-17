# frozen_string_literal: true

module Tramway
  module Core
    module TitleHelper
      def title(page_title = default_title)
        if @application.present?
          title_text = "#{page_title} | #{@application.try(:title) || @application.public_name}"
          content_for(:title) { title_text }
        else
          error = Tramway::Error.new(plugin: :core, method: :title, message: 'You should set Tramway::Core::Application class using `::Tramway::Core.initialize_application model_class: #{model_class_name}` in config/initializers/tramway.rb OR maybe you don\'t have any records of application model')
          raise error.message
        end
      end

      def default_title
        t('.title')
      end

      def page_title(action, model_name)
        if I18n.locale == :ru
          t("helpers.actions.#{action}") + ' ' + genitive(model_name)
        else
          t("helpers.actions.#{action}") + ' ' + model_name.model_name.human.downcase
        end
      end
    end
  end
end
