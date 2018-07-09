require_relative 'spec_helper'
require_relative '../lib/Nouns/NestedFieldItems'

RSpec.describe NestedFieldItems do
    let(:subject) { NestedFieldItems.new('2',['RSpecTest']) }
    describe '#id' do
        it 'gets/sets id with :id' do
            subject.id = '111'
            expect(subject.id).to eq '111'
        end
    end
    describe '#values' do
        it 'gets/sets values with :values' do
            subject.values = ['Sample data']
            expect(subject.values.first).to eq 'Sample data'
        end
    end
    it_behaves_like 'a json builder'
end