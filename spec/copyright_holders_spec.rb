require_relative 'spec_helper'
require_relative '../lib/Nouns/CopyRightHolders'

RSpec.describe CopyRightHolders do
    let(:copyright_holder) { CopyRightHolders.new }
    it 'has a copyright policy id' do
        copyright_holder.copyright_policy_id = '10'
        expect(copyright_holder.id).to eq '10'
    end
    it 'has an id' do
        copyright_holder.id = '1'
        expect(copyright_holder.id).to eq '1'
    end
    it 'has a name' do
        alternate_store.name = 'RSpecTest'
        expect(copyright_holder.name).to eq 'RSpecTest'
    end
    it 'becomes json' do
        expect(copyright_holder.json.is_a(Hash)).to be true
    end
end