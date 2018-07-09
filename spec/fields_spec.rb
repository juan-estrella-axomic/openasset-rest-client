require_relative 'spec_helper'
require_relative '../lib/Nouns/Fields'

RSpec.describe Fields do
    describe 'attributes' do
        it 'gets/sets alive with :alive' do
            subject.alive = '1'
            expect(subject.alive).to eq '1'
        end
        it 'gets/sets cadinality with :cardinality' do
            subject.cardinality = '1'
            expect(subject.cardinality).to eq '1'
        end
        it 'gets/sets code with :code' do
            subject.code = 'MarketingDescription'
            expect(subject.code).to eq 'MarketingDescription'
        end
        it 'gets/sets rest_code with :rest_code' do
            subject.rest_code = 'marketing_description'
            expect(subject.rest_code).to eq 'marketing_description'
        end
        it 'gets/sets descripton with :description' do
            subject.description = 'RSpecTest'
            expect(subject.description).to eq 'RSpecTest'
        end
        it 'gets/sets display_order with :display_order' do
            subject.display_order = '5'
            expect(subject.display_order).to eq '5'
        end
        it 'gets/sets field_display_type with :field_display_type' do
            subject.field_display_type = 'suggestion'
            expect(subject.field_display_type).to eq 'suggestion'
        end
        it 'gets/sets field_type with :field_type' do
            subject.field_type = 'project'
            expect(subject.field_type).to eq 'project'
        end
        it 'gets/sets id with :id' do
            subject.id = '12'
            expect(subject.id).to eq '12'
        end
        it 'gets/sets include_on_info with :include_on_info' do
            subject.include_on_info = '1'
            expect(subject.include_on_info).to eq '1'
        end
        it 'gets/sets include_on_search with :include_on_search' do
            subject.include_on_search = '1'
            expect(subject.include_on_search).to eq '1'
        end
        it 'gets/sets name with :name' do
            subject.name = 'RSpecTest'
            expect(subject.name).to eq 'RSpecTest'
        end
        it 'gets/sets protected with :protected' do
            subject.protected = '1'
            expect(subject.protected).to eq '1'
        end
        it 'gets/sets built_in with :built_in' do
            subject.built_in = '0'
            expect(subject.built_in).to eq '0'
        end
        it 'gets/sets field_lookup_strings with :sfield_lookup_strings' do
            data = {
                'id' => '1',
                'value' => 'RSpecTest',
                'display_order' => '3'
            }
            subject.field_lookup_strings << FieldLookupStrings.new(data)
            expect(subject.field_lookup_strings.first.value).to eq 'RSpecTest'
        end
    end
    it_behaves_like 'a json builder'
end