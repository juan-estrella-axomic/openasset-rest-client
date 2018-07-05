require_relative 'spec_helper'
require_relative '../lib/Nouns/Categories'

RSpec.describe Categories do
    let(:category) { Categories.new }
    it 'is alive' do
        category.alive = '1'
        expect(category.alive).to eq '1'
    end
    it 'has a code' do
        category.code = 'RSpecTest'
        expect(category.code).to eq 'RSpecTest'
    end
    it 'has a default access level' do
        category.default_access_level = '1'
        expect(category.default_access_level).to eq '1'
    end
    it 'has a default rank' do
        category.default_rank = '5'
        expect(category.default_rank).to eq '5'
    end
    it 'has a description' do
        category.description = 'RSpecTest'
        expect(category.description).to eq 'RSpecTest'
    end
    it 'has a display order' do
        category.display_order = '7'
        expect(category.display_order).to eq '7'
    end
    it 'has an id' do
        category.id = '10'
        expect(category.id).to eq '10'
    end
    it 'has a name' do
        category.name = 'RSpecTest'
        expect(category.name).to eq 'RSpecTest'
    end
    it 'can be a projects categoy' do
        category.projects_category = '1'
        expect(category.projects_category).to eq '1'
    end
    it 'becomes json' do
        expect(category.json.is_a(Hash)).to be true
    end
end