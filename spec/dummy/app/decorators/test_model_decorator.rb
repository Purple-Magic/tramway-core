# frozen_string_literal: true

class TestModelDecorator < Tramway::Core::ApplicationDecorator
  decorate_association :association_models, as: :record
  decorate_association :another_association_models
end
