require_relative 'spec_helper'
require_relative '../lib/Nouns/Users'
require_relative '../lib/Nouns/NestedGroupItems'

RSpec.describe Users do
    let(:subject) do
        data = {
            username: 'jdoe@somewhere.com',
            fullname: 'John Doe',
            password: 'secret'
        }
        Users.new(data)
    end
    describe 'attributes' do
        it 'gets/sets email with :email' do
            subject.email = 'jdoe@openasset.com'
            expect(subject.email).to eq 'jdoe@openasset.com'
        end
        it 'gets/sets valid with valid' do
            subject.alive = 1
            expect(subject.alive).to eq 1
        end
        it 'gets/sets alive with :alive' do
            subject.valid = 1
            expect(subject.valid).to eq 1
        end
        it 'gets/sets id with :id' do
            subject.id = '10'
            expect(subject.id).to eq '10'
        end
        it 'gets/sets username with :username' do
            subject.username = 'jdoe@somewhere.com'
            expect(subject.username).to eq 'jdoe@somewhere.com'
        end
        it 'gets/sets full_name with :full_name' do
            subject.full_name = 'John Doe'
            expect(subject.full_name).to eq 'John Doe'
        end
        it 'gets/sets expiry_date with :expiry_date' do
            subject.expiry_date = 'John Doe'
            expect(subject.expiry_date).to eq 'John Doe'
        end
        it 'gets/sets password with :password' do
            subject.password = 'secret'
            expect(subject.password).to eq 'secret'
        end
        it 'gets/sets users with :users' do
            subject.groups << NestedGroupItems.new('7')
            expect(subject.groups.first.id).to eq '7'
        end
    end
    it_behaves_like 'a json builder'
end