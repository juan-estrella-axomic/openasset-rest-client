require_relative 'spec_helper'
require_relative '../lib/Nouns/AccessLevels'

RSpec.describe AccessLevels do
    let(:access_level) { AccessLevels.new }
    describe 'attributes' do
        it 'gets/sets id with :id' do
            access_level.id = '10'
            expect(access_level.id).to eq '10'
        end
        it 'gets/sets label with :label' do
            access_level.label = 'RSpecTest'
            expect(access_level.label).to eq 'RSpecTest'
        end
    end
    describe '#json' do
        it 'converts the object to json' do
            expect(access_level.json.is_a?(Hash)).to be true
        end
    end
end