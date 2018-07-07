require_relative 'spec_helper'
require_relative '../lib/Nouns/AspectRatios'

RSpec.describe AspectRatios do
    describe 'attributes' do
        it 'get/sets id with :id' do
            subject.id = 10
            expect(subject.id).to eq 10
        end
        it 'gets/sets code with :code' do
            subject.code = 'RSpecTest'
            expect(subject.code).to eq 'RSpecTest'
        end
        it 'gets/sets label with :label' do
            subject.label = 'RSpecTest'
            expect(subject.label).to eq 'RSpecTest'
        end
    end
    it_behaves_like 'a json builder'
end