# frozen_string_literal: true

FactoryBot.define do
  factory :association2_model do
    test_model_id { TestModel.last&.id || create(:test_model).id }
    uid { generate :integer }
    text { generate :string }
  end
end
