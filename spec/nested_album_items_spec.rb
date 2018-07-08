require_relative 'spec_helper'
require_relative '../lib/Nouns/NestedAlbumItems'

RSpec.describe NestedAlbumItems do
    describe '#id' do
        it 'gets/sets id with :id' do
            subject.id = '111'
            expect(subject.id).to eq '111'
        end
    end
end