require_relative 'spec_helper'
require_relative '../lib/Nouns/NestedGroupItems'

RSpec.describe NestedGroupItems do
    describe '#id' do
        it 'gets/sets id with :id' do
            subject.id = '112'
            expect(subject.id).to eq '112'
        end
    end
    describe '#can_modify' do
        # can modify only available if second argument is passed
        let(:subject) { NestedGroupItems.new('1','17') }
        it 'gets/sets can_modify with :can_modify' do
            subject.can_modify = '1'
            expect(subject.can_modify).to eq '1'
        end
    end
    it_behaves_like 'a json builder'
end