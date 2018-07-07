require_relative 'spec_helper'
require_relative '../lib/Nouns/Groups'
require_relative '../lib/Nouns/NestedUserItems'

RSpec.describe Groups do
    describe 'attributes' do
        it 'gets/sets alive with :alive' do
            subject.alive = '1'
            expect(subject.alive).to eq '1'
        end
        it 'gets/sets id with :id' do
            subject.id = '10'
            expect(subject.id).to eq '10'
        end
        it 'gets/sets name with :name' do
            subject.name = 'RSpecTest'
            expect(subject.name).to eq 'RSpecTest'
        end
        it 'gets/sets users with :users' do
            subject.users << NestedUserItems.new('33')
            expect(subject.users.first.id).to eq '33'
        end
    end
    it_behaves_like 'a json builder'
end