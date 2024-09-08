module Api
  # Headline Resource Class
  class HeadlinesController < ActionController::API
    CATEGORIES = %w[book-digital book-paper sound-file sound-cd sound-vinyl bookmark-network].freeze

    def headline_params
      params.require(:headline).permit(:category, :title, :description)
    end

    def index
      render json: { headlines: Headline.all }
    end

    def show
      render json: { headline: Headline.find(params[:id]) }
    end

    def create
      headline = Headline.create(headline_params)
      render json: { headline: }
    end

    def update
      headline = Headline.find(params[:id])
      headline.update!(headline_params)
      render json: { headline: }
    end

    def destroy
      headline = Headline.find(params[:id])
      headline.destroy!
    end
  end
end
