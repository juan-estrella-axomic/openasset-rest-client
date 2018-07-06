require_relative 'spec_helper'
require_relative '../lib/Nouns/CopyrightPolicies'

RSpec.describe CopyrightPolicies do
    let(:copyright_policy) { CopyrightPolicies.new }
    describe 'attributes' do
        it 'gets/sets code with :code' do
            copyright_policy.code= 'RSpecTest'
            expect(copyright_policy.code).to eq 'RSpecTest'
        end
        it 'gets/sets description with :description' do
            copyright_policy.description = 'RSpecTest'
            expect(copyright_policy.description).to eq 'RSpecTest'
        end
        it 'gets/sets id with :id' do
            copyright_policy.id = '1'
            expect(copyright_policy.id).to eq '1'
        end
        it 'gets/sets name with :name' do
            copyright_policy.name = 'RSpecTest'
            expect(copyright_policy.name).to eq 'RSpecTest'
        end
    end
    describe '#json' do
        it 'converts object to json' do
            expect(copyright_policy.json.is_a?(Hash)).to be true
        end
    end
end