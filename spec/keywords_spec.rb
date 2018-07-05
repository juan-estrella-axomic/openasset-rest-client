require_relative 'spec_helper'
require_relative '../lib/Nouns/Keywords'

RSpec.describe Keywords do
    let(:keyword) { Keywords.new }
    it 'has an id' do
        keyword.id = '10'
        expect(keyword.id).to eq '10'
    end
    it 'has a keyword category id' do
        keyword.keyword_category_id = '3'
        expect(keyword.keyword_category_id).to eq '3'
    end
    it 'has a name' do
        keyword.name = 'RSpecTest'
        expect(keyword.name).to eq 'RSpecTest'
    end
    it 'becomes json' do
        expect(keyword.json.is_a(Hash)).to be true
    end
end