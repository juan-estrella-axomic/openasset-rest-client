require_relative 'spec_helper'
require_relative '../lib/Nouns/DataIntegrations'

RSpec.describe DataIntegrations do
    describe 'attributes' do
        it 'gets/sets address with :address' do
            subject.address = 'http://test.somewhere.com/Vision/VisionWS.asmx'
            expect(subject.address).to eq 'http://test.somewhere.com/Vision/VisionWS.asmx'
        end
        it 'gets/sets alive with :alive' do
            subject.alive = '1'
            expect(subject.alive).to eq '1'
        end
        it 'gets/sets id with :id' do
            subject.id = '1'
            expect(subject.id).to eq '1'
        end
        it 'gets/sets name with :name' do
            subject.name = 'RSpecTest'
            expect(subject.name).to eq 'RSpecTest'
        end
        it 'gets/sets display_order with :display_order' do
            subject.display_order = '1'
            expect(subject.display_order).to eq '1'
        end
        it 'gets/sets version with :version' do
            subject.version = '7.5.123'
            expect(subject.version).to eq '7.5.123'
        end
    end
    it_behaves_like 'a json builder'
end