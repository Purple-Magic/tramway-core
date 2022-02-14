module Tramway::Core::ApplicationForms::Frontend
  def react_component(on = false)
    @react_component = on
  end

  def is_react_component?
    @react_component ||= false
  end
end
