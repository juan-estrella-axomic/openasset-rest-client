require_relative 'spec_helper'
require_relative '../lib/Nouns/Groups'
require_relative '../lib/Nouns/NestedUserItems'

RSpec.describe Groups do
    let(:group) { Groups.new }
    describe 'attributes' do
        it 'gets/sets alive with :alive' do
            group.alive = '1'
            expect(group.alive).to eq '1'
        end
        it 'gets/sets id with :id' do
            group.id = '10'
            expect(group.id).to eq '10'
        end
        it 'gets/sets name with :name' do
            group.name = 'RSpecTest'
            expect(group.name).to eq 'RSpecTest'
        end
        it 'gets/sets users with :users' do
            group.users << NestedUserItems.new('33')
            expect(group.users.first.id).to eq '33'
        end
    end
    describe '#json' do
        it 'converts object to json' do
            expect(group.json.is_a?(Hash)).to be true
        end
    end
end