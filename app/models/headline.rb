# frozen_string_literal: true

# Headline
class Headline < ActiveRecord::Base
  CATEGORIES = %w[book-digital book-paper sound-file sound-cd sound-vinyl bookmark-network].freeze
  validates :category, presence: true, inclusion: CATEGORIES
  validates :title, presence: true
end
