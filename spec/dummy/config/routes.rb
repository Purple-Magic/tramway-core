# frozen_string_literal: true

Rails.application.routes.draw do
  mount Tramway::Core::Engine => '/tramway-core'
end
