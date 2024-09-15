# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Headline Mode;' do
  before do
    # Do nothing
  end

  after do
    # Do nothing
  end

  context 'when all valid parameters' do
    it 'success' do
      headline = Headline.new
      headline.title = 'test-title'
      headline.category = 'sound-cd'
      headline.description = 'test-description'
      expect(headline.save).to eq(true)
    end
  end

  context 'when all valid parameters with no description' do
    it 'success' do
      headline = Headline.new
      headline.title = 'test-title'
      headline.category = 'sound-cd'
      expect(headline.save).to eq(true)
    end
  end

  context 'when without title' do
    it 'fail' do
      headline = Headline.new
      headline.category = 'sound-cd'
      expect(headline.valid?).to be false
    end
  end

  context 'when without category' do
    it 'fail' do
      headline = Headline.new
      headline.title = 'test-title'
      expect(headline.valid?).to be false
    end
  end
end
