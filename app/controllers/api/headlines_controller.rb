module Api
  # Headline Resource Class
  class HeadlinesController < ActionController::API

    def headline_params
      params.require(:headline).permit(:category, :title, :description)
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
      headline = Headline.create!(headline_params)
      headline.forwardRef_ids = params[:forward_ref_ids].uniq if params[:forward_ref_ids].is_a?(Array)
      render json: { headline: }, include: %i[forwardRefs backwardRefs]
    end

    def update
      headline = Headline.find(params[:id])
      headline.update!(headline_params)
      render json: { headline: }, include: %i[forwardRefs backwardRefs]
    end

    def destroy
      headline = Headline.find(params[:id])
      headline.destroy!
    end
  end
end
