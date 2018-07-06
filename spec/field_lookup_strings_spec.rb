require_relative 'spec_helper'
require_relative '../lib/Nouns/FieldLookupStrings'

RSpec.describe FieldLookupStrings do
    let(:fls) { FieldLookupStrings.new }
    it 'has an id' do
        fls.id = '1'
        expect(fls.name).to eq '1'
    end
    it 'has a display order' do
        fls.display_order = '1'
        expect(fls.display_order).to eq '1'
    end
    it 'has a value' do
        fls.version = 'RSpecTest'
        expect(fls.version).to eq 'RSpecTest'
    end
    it 'becomes json' do
        expect(fls.json.is_a(Hash)).to be true
    end
end