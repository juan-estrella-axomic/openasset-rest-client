require_relative 'spec_helper'
require_relative '../lib/Nouns/CopyRightPolicies'

RSpec.describe CopyRightPolicies do
    let(:copyright_policy) { CopyRightPolicies.new }
    it 'has a code' do
        copyright_policy.copyright_policy_id = '10'
        expect(copyright_policy.copyright_policy_id).to eq '10'
    end
    it 'has a description' do
        copyright_policy.description = 'RSpecTest'
        expect(copyright_policy.description).to eq 'RSpecTest'
    end
    it 'has a id' do
        copyright_policy.id = '1'
        expect(copyright_policy.id).to eq '1'
    end
    it 'has a name' do
        copyright_policy.name = 'RSpecTest'
        expect(copyright_policy.name).to eq 'RSpecTest'
    end
    it 'becomes json' do
        expect(copyright_policy.json.is_a(Hash)).to be true
    end
end