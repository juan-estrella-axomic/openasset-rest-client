require_relative 'spec_helper'
require_relative '../lib/Nouns/AspectRatios'

RSpec.describe AspectRatios do
    let(:aspect_ratio) { AspectRatios.new }
    it 'has an id' do
        aspect_ratio.id = 10
        expect(aspect_ratio.id).to eq 10
    end
    it 'has a code' do
        aspect_ratio.code = 'RSpecTest'
        expect(aspect_ratio.code).to eq 'RSpecTest'
    end
    it 'has a storage label' do
        aspect_ratio.label = 'RSpecTest'
        expect(aspect_ratio.label).to eq 'RSpecTest'
    end
    it 'becomes json' do
        expect(aspect_ratio.json.is_a(Hash)).to be true
    end
end