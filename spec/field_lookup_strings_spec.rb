require_relative 'spec_helper'
require_relative '../lib/Nouns/FieldLookupStrings'

RSpec.describe FieldLookupStrings do
    let(:fls) { FieldLookupStrings.new }
    describe 'attribute' do
        it 'gets/sets id with :id' do
            fls.id = '1'
            expect(fls.id).to eq '1'
        end
        it 'gets/sets display_order wtih :display_order' do
            fls.display_order = '1'
            expect(fls.display_order).to eq '1'
        end
        it 'gets/sets value with :value' do
            fls.value = 'RSpecTest'
            expect(fls.value).to eq 'RSpecTest'
        end
    end
    describe '#json' do
        it 'converts object to json' do
            expect(fls.json.is_a?(Hash)).to be true
        end
    end
end