require_relative 'spec_helper'
require_relative '../lib/Nouns/AlternateStores'

RSpec.describe AlternateStores do
    describe 'attributes' do
        it 'gets/sets id with :id' do
            subject.id = '10'
            expect(subject.id).to eq '10'
        end
        it 'gets/sets name wit :name' do
            subject.name = 'RSpecTest'
            expect(subject.name).to eq 'RSpecTest'
        end
        it 'get/sets storage_name with :storage_name' do
            subject.storage_name = 'RSpecTest'
            expect(subject.storage_name).to eq 'RSpecTest'
        end
    end
    it_behaves_like 'a json builder'
end