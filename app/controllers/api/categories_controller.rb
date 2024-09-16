# frozen_string_literal: true

module Api
  # Headline Resource Class
  class CategoriesController < ActionController::API
    def index
      render json: { categories: Headline::CATEGORIES }
    end
  end
end
