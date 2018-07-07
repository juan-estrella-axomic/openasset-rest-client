require_relative 'spec_helper'
require_relative '../lib/Nouns/FieldLookupStrings'

RSpec.describe FieldLookupStrings do
    describe 'attribute' do
        it 'gets/sets id with :id' do
            subject.id = '1'
            expect(subject.id).to eq '1'
        end
        it 'gets/sets display_order wtih :display_order' do
            subject.display_order = '1'
            expect(subject.display_order).to eq '1'
        end
        it 'gets/sets value with :value' do
            subject.value = 'RSpecTest'
            expect(subject.value).to eq 'RSpecTest'
        end
    end
    it_behaves_like 'a json builder'
end