require_relative 'spec_helper'
require_relative '../lib/Nouns/ProjectKeywordCategories'

RSpec.describe ProjectKeywordCategories do
    describe 'attributes' do
        it 'gets/sets code with :code' do
            subject.code = 'Client'
            expect(subject.code).to eq 'Client'
        end
        it 'gets/sets display_order with :display_order' do
            subject.display_order = '1'
            expect(subject.display_order).to eq '1'
        end
        it 'gets/sets id with :id' do
            subject.id = '1'
            expect(subject.id).to eq '1'
        end
        it 'get/sets name with :name' do
            subject.name = 'RSpecTest'
            expect(subject.name).to eq 'RSpecTest'
        end
    end
    it_behaves_like 'a json builder'
end