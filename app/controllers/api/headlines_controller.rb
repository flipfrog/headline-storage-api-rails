# frozen_string_literal: true

module Api
  # Headline Resource Class
  class HeadlinesController < ActionController::API

    def headline_params
      params.require(:headline).permit(:category, :title, :description, forward_ref_ids: [])
    end

    def index
      categories = (params[:categories] || '')
                   .split(',')
                   .select { |category| Headline::CATEGORIES.include? category }
      headlines = Headline
                  .then { |relation| search_by_categories(relation, categories) }
                  .order :id
      render json: { headlines: }, include: %i[forwardRefs backwardRefs]
    end

    def search_by_categories(relation, categories)
      if categories.length.positive?
        relation.where(category: categories)
      else
        relation.all
      end
    end

    def show
      headline = Headline.find(params[:id])
      render json: { headline: }, include: %i[forwardRefs backwardRefs]
    end

    def create
      ActiveRecord::Base.transaction do
        @headline = Headline.create!(headline_params)
        update_forward_refs
      end
      render json: { headline: @headline }, include: %i[forwardRefs backwardRefs]
    end

    def update
      @headline = Headline.find(params[:id])
      ActiveRecord::Base.transaction do
        @headline.update!(headline_params)
        update_forward_refs
      end
      render json: { headline: @headline }, include: %i[forwardRefs backwardRefs]
    end

    def destroy
      headline = Headline.find(params[:id])
      headline.destroy!
    end

    def update_forward_refs
      request_forward_ref_ids = params['forward_ref_ids'] if params['forward_ref_ids'].is_a?(Array)
      request_forward_ref_ids = (request_forward_ref_ids || []).excluding @headline.backwardRef_ids
      @headline.forwardRef_ids = request_forward_ref_ids.uniq
    end
  end
end
