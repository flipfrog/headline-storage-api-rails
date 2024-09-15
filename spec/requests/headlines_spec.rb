# frozen_string_literal: true

require 'rails_helper'

describe 'Headlines' do

  describe 'GET /api/headlines' do
    let(:params) { {} }
    let!(:expected1) { create(:headline, { category: 'sound-cd' }) }
    let!(:expected2) { create(:headline, { category: 'book-digital' }) }

    subject do
      get api_headlines_path, params:
    end

    context 'with no parameter' do
      it 'gets no headlines' do
        expected1.destroy!
        expected2.destroy!

        subject

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['headlines']).to eq([])
      end

      it 'gets all headlines' do
        subject

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['headlines'].pluck(:id)).to eq([expected1.id, expected2.id])
      end

      it 'gets headlines with refs' do
        expected1.forwardRefs << expected2

        subject

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['headlines'].pluck(:id)).to eq([expected1.id, expected2.id])
        expect(response.parsed_body['headlines'][0]['forwardRefs'][0]['id']).to eq(expected2.id)
        expect(response.parsed_body['headlines'][1]['backwardRefs'][0]['id']).to eq(expected1.id)
      end
    end

    context 'with one category parameter' do
      let(:params) { { categories: 'sound-cd' } }

      it 'gets one category headline' do
        subject

        expect(response).to have_http_status(200)
        expect(response.parsed_body['headlines'].pluck(:id)).to eq([expected1.id])
      end
    end

    context 'with ignored categories param' do
      let(:params) { { ignored_categories: 'ignored' } }

      it 'gets all headlines' do

        subject

        expect(response).to have_http_status(200)
        expect(response.parsed_body['headlines'].pluck(:id)).to eq([expected1.id, expected2.id])
      end
    end
  end

  describe 'GET /api/headlines/:id' do
    let(:headlines_id) { '' }
    let!(:expected) { create(:headline, { title: 'test title', category: 'sound-cd' }) }

    subject do
      get api_headline_path(headlines_id)
    end

    context 'with valid id parameters' do
      let(:headlines_id) { expected.id }

      it 'gets headline' do
        subject

        expect(response).to have_http_status(200)
        expect(response.parsed_body['headline']['id']).to eq(expected.id)
      end

      it 'gets headline with refs' do
        expected2 = create(:headline, { title: 'test title 2', category: 'book-paper' })
        expected.forwardRefs << expected2
        subject

        expect(response).to have_http_status(200)
        expect(response.parsed_body['headline']['id']).to eq(expected.id)
        expect(response.parsed_body['headline']['forwardRefs'].pluck('id')).to eq([expected2.id])
        expect(response.parsed_body['headline']['backwardRefs']).to eq([])
      end
    end

    context 'with invalid id parameters' do
      let(:headlines_id) { expected.id + 1 }

      it 'gets headline' do
        subject

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /api/headlines/:id' do

  end

  describe 'PUT /api/headlines/:id' do

  end

  describe 'DELETE /api/headlines/:id' do

  end
end
