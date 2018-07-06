require_relative 'spec_helper'
require_relative '../lib/Nouns/AspectRatios'

RSpec.describe AspectRatios do
    let(:aspect_ratio) { AspectRatios.new }
    describe 'attributes' do
        it 'get/sets id with :id' do
            aspect_ratio.id = 10
            expect(aspect_ratio.id).to eq 10
        end
        it 'gets/sets code with :code' do
            aspect_ratio.code = 'RSpecTest'
            expect(aspect_ratio.code).to eq 'RSpecTest'
        end
        it 'gets/sets label with :label' do
            aspect_ratio.label = 'RSpecTest'
            expect(aspect_ratio.label).to eq 'RSpecTest'
        end
    end
    describe '#json' do
        it 'converts the object to json' do
            expect(aspect_ratio.json.is_a?(Hash)).to be true
        end
    end
end