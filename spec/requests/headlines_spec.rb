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

  describe 'GET /api/headlines' do
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

      it 'to get headline' do
        subject

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /api/headlines' do
    let(:params) { { title: 'test title', category: 'sound-cd', description: 'test description' } }
    subject do
      post api_headlines_path, params: params, as: :json
    end

    context 'with valid params' do
      it 'stores headline' do
        subject

        expect(response).to have_http_status(:success)
        expect(Headline.last).to have_attributes(
          title: 'test title',
          category: 'sound-cd',
          description: 'test description'
        )
      end

      it 'stores headline with nil description' do
        params['description'] = nil
        subject

        expect(response).to have_http_status(:success)
        expect(Headline.last).to have_attributes(
          title: 'test title',
          category: 'sound-cd',
          description: nil
        )
      end

      it 'stores headline with refs' do
        headline = create(:headline, { title: 'test title 2', category: 'book-digital' })
        params['forward_ref_ids'] = [headline.id]

        subject

        expect(response).to have_http_status(:success)
        expect(Headline.last).to have_attributes(
          title: 'test title',
          category: 'sound-cd',
          description: 'test description'
        )
        expect(Headline.last.forwardRef_ids).to eq([headline.id])
        expect(Headline.first.backwardRef_ids).to eq([Headline.last.id])
      end

      it 'store headline with duplicate forward refs to unique ids' do
        headline = create(:headline, { title: 'test title 2', category: 'book-paper' })
        params['forward_ref_ids'] = [headline.id, headline.id]

        subject

        expect(response).to have_http_status(:success)
        expect(Headline.last).to have_attributes(
          title: 'test title',
          category: 'sound-cd',
          description: 'test description'
        )
        expect(Headline.last.forwardRef_ids).to eq([headline.id])
      end

      it 'store headline ignoring forward_ref_ids which is not array' do
        params['forward_ref_ids'] = 'invalid'
        subject

        expect(response).to have_http_status(:success)
        expect(Headline.last).to have_attributes(
          title: 'test title',
          category: 'sound-cd',
          description: 'test description'
        )
      end
    end

    context 'with invalid params' do
      it 'to store headline with long title' do
        params['title'] = 'a' * 101

        subject

        expect(response).to have_http_status(422)
      end

      it 'to store headline with invalid category' do
        params['category'] = 'invalid'

        subject

        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PUT /api/headlines' do
    let!(:headline) { create(:headline, { title: 'test title', category: 'sound-cd' }) }
    let(:params) { { title: 'test title-x', category: 'sound-vinyl', description: 'test description' } }

    subject do
      put api_headline_path(headline.id), params: params, as: :json
    end

    context 'with valid params' do
      it 'updates headline' do
        subject

        expect(response).to have_http_status(:success)
        expect(Headline.first).to have_attributes(
          title: 'test title-x',
          category: 'sound-vinyl',
          description: 'test description'
        )
      end

      it 'updates headline with nil description' do
        params['description'] = nil
        subject

        expect(Headline.first).to have_attributes(
          title: 'test title-x',
          category: 'sound-vinyl',
          description: nil
        )
      end

      it 'updates headline with refs' do
        ref = create(:headline, { title: 'test title ref', category: 'book-digital' })
        params['forward_ref_ids'] = [ref.id]

        subject

        expect(response).to have_http_status(:success)
        expect(Headline.first).to have_attributes(
          title: 'test title-x',
          category: 'sound-vinyl',
          description: 'test description'
        )
        expect(Headline.first.forwardRef_ids).to eq([ref.id])
        expect(ref.backwardRef_ids).to eq([headline.id])
      end

      it 'updates headline with duplicate forward refs to unique ids' do
        ref = create(:headline, { title: 'test title ref', category: 'book-digital' })
        params['forward_ref_ids'] = [ref.id, ref.id]

        subject

        expect(response).to have_http_status(:success)
        expect(Headline.first.forwardRef_ids).to eq([ref.id])
        expect(ref.backwardRef_ids).to eq([headline.id])
      end

      it 'updates headline ignoring forward_ref_ids which is not array' do
        params['forward_ref_ids'] = 'invalid'

        subject

        expect(response).to have_http_status(:success)
        expect(Headline.first).to have_attributes(
          title: 'test title-x',
          category: 'sound-vinyl',
          description: 'test description'
        )
        expect(Headline.first.forwardRef_ids).to eq([])
      end
    end

    context 'with invalid params' do
      it 'to update headline with long title' do
        params['title'] = 'a' * 101

        subject

        expect(response).to have_http_status(422)
      end

      it 'to update headline with invalid category' do
        params['category'] = 'invalid'

        subject

        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE /api/headlines' do
    let!(:headline) { create(:headline, { title: 'test title', category: 'sound-cd' }) }

    subject do
      delete api_headline_path(headline.id)
    end

    context 'with valid params' do
      it 'deletes headline' do
        subject

        expect(response).to have_http_status(:success)
        expect(Headline.exists?(headline.id)).to eq(false)
      end

      it 'deletes headline having refs' do
        headline2 = create(:headline, { title: 'test title 2', category: 'sound-file' })
        headline.forwardRefs << headline2
        headline.reload
        expect(Headline.last.backwardRef_ids).to eq([headline.id])

        subject

        expect(response).to have_http_status(:success)
        expect(Headline.exists?(headline.id)).to eq(false)
        expect(Headline.exists?(headline2.id)).to eq(true)
        expect(Headline.last.backwardRef_ids).to eq([])
      end
    end

    context 'with invalid params' do
      it 'to delete headline with invalid id' do
        delete api_headline_path(headline.id + 1)

        expect(response).to have_http_status(404)
      end
    end
  end
end
