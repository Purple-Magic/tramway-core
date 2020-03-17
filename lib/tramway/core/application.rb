# frozen_string_literal: true

class Tramway::Core::Application
  attr_accessor :name, :url, :model_class, :title, :tagline, :found_date, :phone, :email

  def public_name
    name.to_s.gsub('_', ' ').camelize
  end
end
