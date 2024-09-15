# frozen_string_literal: true

# headlines_headlines
class CreateHeadlinesHeadlines < ActiveRecord::Migration[7.1]
  def change
    create_table :headlines_headlines do |t|
      t.integer :origin_id
      t.integer :end_id
      t.timestamps
    end
  end
end
