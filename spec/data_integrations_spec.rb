require_relative 'spec_helper'
require_relative '../lib/Nouns/DataIntegrations'

RSpec.describe DataIntegrations do
    let(:data_integration) { DataIntegrations.new }
    it 'has an address' do
        data_integration.address = 'http://test.somewhere.com/Vision/VisionWS.asmx'
        expect(data_integration.address).to eq 'http://test.somewhere.com/Vision/VisionWS.asmx'
    end
    it 'is alive' do
        data_integration.alive = '1'
        expect(data_integration.alive).to eq '1'
    end
    it 'has an id' do
        alternate_store.id = '1'
        expect(data_integration.name).to eq '1'
    end
    it 'has a name' do
        alternate_store.name = 'RSpecTest'
        expect(data_integration.name).to eq 'RSpecTest'
    end
    it 'has a display order' do
        alternate_store.display_order = '1'
        expect(data_integration.display_order).to eq '1'
    end
    it 'has a version' do
        alternate_store.version = '7.5.123'
        expect(data_integration.version).to eq '7.5.123'
    end
    it 'becomes json' do
        expect(data_integration.json.is_a(Hash)).to be true
    end
end