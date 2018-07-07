require_relative 'spec_helper'
require_relative '../lib/Nouns/Location'

RSpec.describe Location do
        # @address = json_obj['address']
        # @city = json_obj['city']
        # @country = json_obj['country']
        # @google_id = json_obj['google_id']
        # @latitude = json_obj['latitude']
        # @longitude = json_obj['longitude']
        # @name = json_obj['name']
        # @postal_code = json_obj['postal_code']
        # @state = json_obj['state']
        # @street = json_obj['street']
        # @street_number = json_obj['street_number']
    describe 'attributes' do
        it 'gets/sets address with :address' do
            subject.address = '999 main st'
            expect(subject.address).to eq '999 main st'
        end
        it 'gets/sets city with :city' do
            subject.city = 'New York'
            expect(subject.city).to eq 'New York'
        end
        it 'gets/sets country with :country' do
            subject.country = 'USA'
            expect(subject.country).to eq 'USA'
        end
        it 'gets/sets google_id with :google_id' do
            subject.google_id = '1234567890abcdef'
            expect(subject.google_id).to eq '1234567890abcdef'
        end
        it 'gets/sets latitude with :latitude' do
            subject.latitude = '88.1234'
            expect(subject.latitude).to eq '88.1234'
        end
        it 'gets/sets longitude with :longitude' do
            subject.longitude = '178.2345'
            expect(subject.longitude).to eq '178.2345'
        end
        it 'gets/set name with :name' do
            subject.name = 'RSpecTest'
            expect(subject.name).to eq 'RSpecTest' 
        end
        it 'gets/sets postal_code with :postal_code' do
            subject.postal_code = '07026'
            expect(subject.postal_code).to eq '07026'
        end
        it 'sets/sets state wtih :state' do
            subject.state = 'NJ'
            expect(subject.state).to eq 'NJ'
        end
        it 'gets/sets street with :street' do
            subject.street = 'main st'
            expect(subject.street).to eq 'main st'
        end
        it 'gets/sets street_number with :street_number' do
            subject.street_number = '123'
            expect(subject.street_number).to eq '123'
        end
    end
    it_behaves_like 'a json builder'
end