# frozen_string_literal: true

# Headlines
class CreateHeadlines < ActiveRecord::Migration[7.1]
  def change
    create_table :headlines do |t|
      t.string :title, null: false, limit: 100
      t.string :category, null: false
      t.string :description

      t.timestamps
    end
  end
end
