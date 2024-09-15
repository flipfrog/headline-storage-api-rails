# frozen_string_literal: true

# Headline
class Headline < ActiveRecord::Base
  CATEGORIES = %w[book-digital book-paper sound-file sound-cd sound-vinyl bookmark-network].freeze
  validates :category, presence: true, inclusion: CATEGORIES
  validates :title, presence: true, length: { maximum: 100 }

  has_and_belongs_to_many :forwardRefs,
                          join_table: 'headlines_headlines',
                          foreign_key: :origin_id,
                          association_foreign_key: :end_id,
                          class_name: 'Headline'

  has_and_belongs_to_many :backwardRefs,
                          join_table: 'headlines_headlines',
                          foreign_key: :end_id,
                          association_foreign_key: :origin_id,
                          class_name: 'Headline'
end
