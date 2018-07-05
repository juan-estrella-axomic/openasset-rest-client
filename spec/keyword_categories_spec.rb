require_relative 'spec_helper'
require_relative '../lib/Nouns/KeywordCategories'

RSpec.describe AlternateStores do
    let(:keyword_category) { KeywordCategories.new }
    it 'has a category id' do
        keyword_category.id = '9'
        expect(keyword_category.id).to eq '9'
    end
    it 'has a code' do
        keyword_category.code = 'RSpecTest'
        expect(keyword_category.code).to eq 'RSpecTest'
    end
    it 'has an id' do
        keyword_category.id = '10'
        expect(keyword_category.id).to eq '10'
    end
    it 'has a display order' do
        keyword_category.display_order = '9'
        expect(keyword_category.display_order).to eq '9'
    end
    it 'has a name' do
        keyword_category.name = 'RSpecTest'
        expect(keyword_category.name).to eq 'RSpecTest'
    end
    it 'becomes json' do
        expect(keyword_category.json.is_a(Hash)).to be true
    end
end