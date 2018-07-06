require_relative 'spec_helper'
require_relative '../lib/Nouns/CopyrightHolders'

RSpec.describe CopyrightHolders do
    let(:copyright_holder) { CopyrightHolders.new }
    describe 'attributes' do
        it 'gets/sets copyright_policy_id with :copyright_policy_id' do
            copyright_holder.copyright_policy_id = '10'
            expect(copyright_holder.copyright_policy_id).to eq '10'
        end
        it 'gets/sets id with :id' do
            copyright_holder.id = '1'
            expect(copyright_holder.id).to eq '1'
        end
        it 'gets/sets name with :name' do
            copyright_holder.name = 'RSpecTest'
            expect(copyright_holder.name).to eq 'RSpecTest'
        end
    end
    describe '#json' do
        it 'converts object to json' do
            expect(copyright_holder.json.is_a?(Hash)).to be true
        end
    end
end