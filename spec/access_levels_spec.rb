require_relative 'spec_helper'
require_relative '../lib/Nouns/AccessLevels'

RSpec.describe AccessLevels do
    describe 'attributes' do
        it 'gets/sets id with :id' do
            subject.id = '10'
            expect(subject.id).to eq '10'
        end
        it 'gets/sets label with :label' do
            subject.label = 'RSpecTest'
            expect(subject.label).to eq 'RSpecTest'
        end
    end
    it_behaves_like 'a json builder'
end