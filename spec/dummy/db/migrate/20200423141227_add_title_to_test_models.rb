# frozen_string_literal: true

class AddTitleToTestModels < ActiveRecord::Migration[6.0]
  def change
    add_column :test_models, :title, :text
  end
end
