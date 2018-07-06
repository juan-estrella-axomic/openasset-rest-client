require_relative 'spec_helper'
require_relative '../lib/Nouns/DataIntegrations'

RSpec.describe DataIntegrations do
    let(:data_integration) { DataIntegrations.new }
    describe 'attributes' do
        it 'gets/sets address with :address' do
            data_integration.address = 'http://test.somewhere.com/Vision/VisionWS.asmx'
            expect(data_integration.address).to eq 'http://test.somewhere.com/Vision/VisionWS.asmx'
        end
        it 'gets/sets alive with :alive' do
            data_integration.alive = '1'
            expect(data_integration.alive).to eq '1'
        end
        it 'gets/sets id with :id' do
            data_integration.id = '1'
            expect(data_integration.id).to eq '1'
        end
        it 'gets/sets name with :name' do
            data_integration.name = 'RSpecTest'
            expect(data_integration.name).to eq 'RSpecTest'
        end
        it 'gets/sets display_order with :display_order' do
            data_integration.display_order = '1'
            expect(data_integration.display_order).to eq '1'
        end
        it 'gets/sets version with :version' do
            data_integration.version = '7.5.123'
            expect(data_integration.version).to eq '7.5.123'
        end
    end
    describe '#json' do
        it 'converts object to json' do
            expect(data_integration.json.is_a?(Hash)).to be true
        end
    end
end