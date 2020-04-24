# frozen_string_literal: true

module Tramway::Core::ApplicationForms::AssociationObjectHelpers
  def define_association_method(association, class_name)
    if class_name.is_a? Array
      define_polymorphic_association association, class_name
    else
      self.class.send(:define_method, "#{association}=") do |value|
        model.send "#{association}_id=", value
        model.send "#{association}=", class_name.find(value)
      end
    end
  end

  def define_polymorphic_association(association, _class_name)
    self.class.send(:define_method, "#{association}=") do |value|
      association_class = value.split('_')[0..-2].join('_').camelize
      association_class = association_class.constantize if association_class.is_a? String
      if association_class.nil?
        Tramway::Error.raise_error :tramway, :core, :application_form, :initialize, :polymorphic_class_is_nil,
          association_name: association
      else
        model.send "#{association}=", association_class.find(value.split('_')[-1])
        send "#{association}_type=", association_class.to_s
      end
    end
  end
end
