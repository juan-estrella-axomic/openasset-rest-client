require_relative 'spec_helper'
require_relative '../lib/Nouns/NestedFileItems'

RSpec.describe NestedFileItems do
    describe '#id' do
        it 'gets/sets id with :id' do
            subject.id = '112'
            expect(subject.id).to eq '112'
        end
    end
end