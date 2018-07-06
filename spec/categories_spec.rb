require_relative 'spec_helper'
require_relative '../lib/Nouns/Categories'

RSpec.describe Categories do
    let(:category) { Categories.new }
    describe 'attributes' do
        it 'gets/sets alive with :alive' do
            category.alive = '1'
            expect(category.alive).to eq '1'
        end
        it 'gets/sets code with :code' do
            category.code = 'RSpecTest'
            expect(category.code).to eq 'RSpecTest'
        end
        it 'gets/sets default_access_level with :default_access_level' do
            category.default_access_level = '1'
            expect(category.default_access_level).to eq '1'
        end
        it 'gets/sets default_rank with :default_rank' do
            category.default_rank = '5'
            expect(category.default_rank).to eq '5'
        end
        it 'gets/sets description with :description' do
            category.description = 'RSpecTest'
            expect(category.description).to eq 'RSpecTest'
        end
        it 'gets/sets display_order with :display_order' do
            category.display_order = '7'
            expect(category.display_order).to eq '7'
        end
        it 'gets/sets id with :id' do
            category.id = '10'
            expect(category.id).to eq '10'
        end
        it 'gets/gets name with :name' do
            category.name = 'RSpecTest'
            expect(category.name).to eq 'RSpecTest'
        end
        it 'gets/sets projects_categoy with :projects_category' do
            category.projects_category = '1'
            expect(category.projects_category).to eq '1'
        end
    end
    describe '#json' do
        it 'converts the object to json' do
            expect(category.json.is_a?(Hash)).to be true
        end
    end
end