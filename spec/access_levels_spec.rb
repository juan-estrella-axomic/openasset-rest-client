require_relative 'spec_helper'
require_relative '../lib/Nouns/AccessLevels'

RSpec.describe AccessLevels do

    describe '#id' do
        let(:access_level) { AccessLevels.new }
        access_level.id = '10'
        it 'sets and returns the id' do
            expect(access_level.id).to eq '10'
        end
    end
    describe '#label' do
        let(:access_level) { AccessLevels.new }
        access_level.label = 'RSpecTest'
        it 'sets and returns the label' do
            expect(access_level.label).to eq 'RSpecTest'
        end
    end
    describe '#json' do
        let(:access_level) { AccessLevels.new }
        it 'converts the object to json' do
            expect(access_level.json.is_a(Hash)).to be true
        end
    end
end