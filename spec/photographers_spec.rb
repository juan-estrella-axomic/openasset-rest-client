require_relative 'spec_helper'
require_relative '../lib/Nouns/Photographers'

RSpec.describe Photographers do
    describe 'attributes' do
        it 'gets/sets id with :id' do
            subject.id = '111'
            expect(subject.id).to eq '111'
        end
        it 'get/sets name with :name' do
            subject.id = 'RSpecTest'
            expect(subject.id).to eq 'RSpecTest'
        end
    end
    it_behaves_like 'a json builder'
end