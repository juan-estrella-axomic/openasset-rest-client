require_relative 'spec_helper'
require_relative '../lib/Nouns/Groups'
require_relative '../lib/Nouns/NestedUserItems'

RSpec.describe Groups do
    describe 'attributes' do
        it 'gets/sets hidden with :hidden' do
            subject.hidden = 0
            expect(subject.hidden).to eq 0
        end
        it 'gets/sets alive with :alive' do
            subject.alive = 1
            expect(subject.alive).to eq 1
        end
        it 'gets/sets name with :name' do
            subject.name = 'RSpecTest'
            expect(subject.name).to eq 'RSpecTest'
        end
        it 'gets/sets id with :id' do
            subject.id = 10
            expect(subject.id).to eq 10
        end
        it 'gets/sets default_for_new_users with :default_for_new_users' do
            subject.default_for_new_users = 1
            expect(subject.default_for_new_users).to eq 1
        end
        it 'gets/sets expires with :expires' do
            subject.expires = 1
            expect(subject.expires).to eq 1
        end
        it 'gets/sets expiry_date with :expiry_date' do
            subject.expiry_date = '20370101010101'
            expect(subject.expiry_date).to eq '20370101010101'
        end
        it 'gets/sets users with :users' do
            subject.users << NestedUserItems.new('33')
            expect(subject.users.first.id).to eq '33'
        end
    end
    it_behaves_like 'a json builder'
end