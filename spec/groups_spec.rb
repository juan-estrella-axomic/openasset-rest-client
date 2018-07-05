require_relative 'spec_helper'
require_relative '../lib/Nouns/Groups'
require_relative '../lib/NestedUserItems'

RSpec.describe Groups do
    let(:group) { Groups.new }
    it 'is alive' do
        group.alive = '1'
        expect(group.alive).to eq '1'
    end
    it 'has an id' do
        group.id = '10'
        expect(group.id).to eq '10'
    end
    it 'has a name' do
        group.name = 'RSpecTest'
        expect(group.name).to eq 'RSpecTest'
    end
    it 'has users' do
        group.users << NestedUserItems.new('33')
        expect(group.users.first.id).to eq '33'
    end
    it 'becomes json' do
        expect(group.json.is_a(Hash)).to be true
    end
end