require_relative 'spec_helper'
require_relative '../lib/Nouns/AlternateStores'

RSpec.describe AlternateStores do
    let(:alternate_store) { AlternateStores.new }
    describe 'attributes' do
        it 'gets/sets id with :id' do
            alternate_store.id = '10'
            expect(alternate_store.id).to eq '10'
        end
        it 'gets/sets name wit :name' do
            alternate_store.name = 'RSpecTest'
            expect(alternate_store.name).to eq 'RSpecTest'
        end
        it 'get/sets storage_name with :storage_name' do
            alternate_store.storage_name = 'RSpecTest'
            expect(alternate_store.storage_name).to eq 'RSpecTest'
        end
    end
    describe 'json' do
        it 'converts the object to json' do
            expect(alternate_store.json.is_a?(Hash)).to be true
        end
    end
end