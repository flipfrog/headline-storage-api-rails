# frozen_string_literal: true

require 'rails_helper'

describe 'GET Headlines' do

  let(:params) { {} }

  subject do
    get '/api/headlines', params:
  end

  context 'with no parameter' do
    it 'gets no headlines' do
      subject

      expect(response).to have_http_status(:success)
      expect(response.parsed_body['headlines']).to eq([])
    end

    it 'gets all headlines' do
      expected1 = create(:headline, { category: 'sound-cd' })
      expected2 = create(:headline, { category: 'book-digital' })

      subject

      expect(response).to have_http_status(:success)
      expect(response.parsed_body['headlines'].pluck(:id)).to match_array([expected1.id, expected2.id])
    end
  end

  context 'with one category parameter' do
    let(:params) { { categories: 'sound-cd' } }

    it 'gets one category headline' do
      expected = create(:headline, { category: 'sound-cd' })
      create(:headline, { category: 'book-digital' })

      subject

      expect(response).to have_http_status(200)
      expect(response.parsed_body['headlines'].pluck(:id)).to match_array([expected.id])
    end
  end

  context 'with ignored categories param' do
    let(:params) { { ignored_categories: 'sound-ignored' } }

    it 'gets all headlines' do
      expected1 = create(:headline, { category: 'sound-cd' })
      expected2 = create(:headline, { category: 'book-digital' })

      subject

      expect(response).to have_http_status(200)
      expect(response.parsed_body['headlines'].pluck(:id)).to match_array([expected1.id, expected2.id])
    end
  end
end
