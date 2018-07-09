require_relative 'spec_helper'
require_relative '../lib/Nouns/Projects'
require_relative '../lib/Nouns/Location'
require_relative '../lib/Nouns/NestedProjectKeywordItems'
require_relative '../lib/Nouns/NestedFieldItems'
require_relative '../lib/Nouns/NestedAlbumItems'

RSpec.describe Projects do
    describe 'attirbutes' do
        it 'gets/sets alive with :alive' do
            subject.alive = '1'
            expect(subject.alive).to eq '1'
        end
        it 'gets/sets code with :code' do
            subject.code = '00.9053.006'
            expect(subject.code).to eq '00.9053.006'
        end
        it 'gets/sets code_alias_1 with :code_alias_1' do
            subject.code_alias_1 = 'RSpecProject'
            expect(subject.code_alias_1).to eq 'RSpecProject'
        end
        it 'gets/sets code_alias_2 with :code_alias_2' do
            subject.code_alias_2 = 'RSpecProject2'
            expect(subject.code_alias_2).to eq 'RSpecProject2'
        end
        it 'gets/sets hero_image_id with :hero_image_id' do
            subject.hero_image_id = '451'
            expect(subject.hero_image_id).to eq '451'
        end
        it 'gets/sets id with :id' do
            subject.id = '111'
            expect(subject.id).to eq '111'
        end
        it 'gets/sets name with :name' do
            subject.name= 'RSpecTest'
            expect(subject.name).to eq 'RSpecTest'
        end
        it 'gets/sets name_alias_1 with :name_alias_1' do
            subject.name_alias_1 = 'RSpecProject'
            expect(subject.name_alias_1).to eq 'RSpecProject'
        end
        it 'gets/sets code_alias_2 with :code_alias_2' do
            subject.name_alias_2 = 'RSpecProject2'
            expect(subject.name_alias_2).to eq 'RSpecProject2'
        end
        it 'gets/sets location with :location' do
            location = Location.new
            location.set_coordinates('40.7128 N, 74.0060 W') #NYC
            subject.location = location
            expect(subject.location.is_a?(Location)).to be true
        end
        it 'gets/sets project_keywords with :project_keywords' do
            subject.project_keywords << NestedProjectKeywordItems.new('17')
            expect(subject.project_keywords.first.id).to eq '17'
        end
        it 'gets/sets fields with :fields' do
            subject.fields << NestedFieldItems.new('18','data')
            expect(subject.fields.first.values).to eq ['data']
        end
        it 'gets/sets albums with :albums' do
            subject.fields << NestedAlbumItems.new('33')
            expect(subject.fields.first.id).to eq '33'
        end
    end
    it_behaves_like 'a json builder'
end