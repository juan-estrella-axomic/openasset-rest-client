require_relative 'spec_helper'
require_relative '../lib/Nouns/KeywordCategories'

RSpec.describe KeywordCategories do]
    describe 'attributes' do
        it 'gets/sets category_id with :category_id' do
            subject.category_id = '9'
            expect(subject.category_id).to eq '9'
        end
        it 'gets/sets code with :code' do
            subject.code = 'RSpecTest'
            expect(subject.code).to eq 'RSpecTest'
        end
        it 'gets/sets display_order with :display_order' do
            subject.display_order = '9'
            expect(subject.display_order).to eq '9'
        end
        it 'gets/sets id with :id' do
            subject.id = '10'
            expect(subject.id).to eq '10'
        end
        it 'gets/sets name with :name' do
            subject.name = 'RSpecTest'
            expect(subject.name).to eq 'RSpecTest'
        end
    end
    it_behaves_like 'a json builder'
end