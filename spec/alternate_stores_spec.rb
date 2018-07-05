require_relative 'spec_helper'
require_relative '../lib/Nouns/AlternateStores'

RSpec.describe AlternateStores do
    let(:alternate_store) { AlternateStores.new }
    it 'has an id' do
        alternate_store.id = '10'
        expect(alternate_store.id).to eq '10'
    end
    it 'has a name' do
        alternate_store.name = 'RSpecTest'
        expect(alternate_store.name).to eq 'RSpecTest'
    end
    it 'has a storage name' do
        alternate_store.name = 'RSpecTest'
        expect(alternate_store.storage_name).to eq 'RSpecTest'
    end
    it 'becomes json' do
        expect(alternate_store.json.is_a(Hash)).to be true
    end
end