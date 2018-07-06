require_relative 'spec_helper'
require_relative '../lib/Nouns/Location'

RSpec.describe Location do
    let(:location) { Location.new }
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
    describe '#address' do
        it 'has an address' do
            location.address = '999 main st'
            expect(location.address).to eq '999 main st'
        end
    end
    it 'has a city' do

    end
    it 'has a country' do

    end
    it 'has a google id' do

    end
    it 'has a latitude' do

    end
    it 'has a longitude' do

    end
    it 'has a name' do

    end
    it 'has a postal code' do

    end
    it 'has a state' do

    end
    it 'has a street' do

    end
    it 'has a street number' do

    end
end