# frozen_string_literal: true

# Headlines
class CreateHeadlines < ActiveRecord::Migration[7.1]
  def change
    create_table :headlines do |t|
      t.string :title
      t.string :category
      t.string :description

      t.timestamps
    end
  end
end
