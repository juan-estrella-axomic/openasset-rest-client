require_relative 'spec_helper'
require_relative '../lib/Nouns/Keywords'

RSpec.describe Keywords do
    describe 'attributes' do
        it 'gets/sets id with :id' do
            subject.id = '10'
            expect(subject.id).to eq '10'
        end
        it 'gets/sets subject_category_id' do
            subject.keyword_category_id = '3'
            expect(subject.keyword_category_id).to eq '3'
        end
        it 'gets/sets name with :name' do
            subject.name = 'RSpecTest'
            expect(subject.name).to eq 'RSpecTest'
        end
    end
    it_behaves_like 'a json builder'
end