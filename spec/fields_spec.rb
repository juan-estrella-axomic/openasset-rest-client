require_relative 'spec_helper'
require_relative '../lib/Nouns/Fields'

RSpec.describe Fields do
    let(:field) { Fields.new }
    describe 'attributes' do
        it 'gets/sets alive with :alive' do
            field.alive = '1'
            expect(field.alive).to eq '1'
        end
        it 'gets/sets cadinality with :cardinality' do
            field.cardinality = '1'
            expect(field.cardinality).to eq '1'
        end
        it 'gets/sets code with :code' do
            field.code = 'MarketingDescription'
            expect(field.code).to eq 'MarketingDescription'
        end
        it 'gets/sets rest_code with :rest_code' do
            field.rest_code = 'marketing_description'
            expect(field.rest_code).to eq 'marketing_description'
        end
        it 'gets/sets descripton with :description' do
            field.description = 'RSpecTest'
            expect(field.description).to eq 'RSpecTest'
        end
        it 'gets/sets display_order with :display_order' do
            field.display_order = '5'
            expect(field.display_order).to eq '5'
        end
        it 'gets/sets field_display_type with :field_display_type' do
            field.field_display_type = 'suggestion'
            expect(field.field_display_type).to eq 'suggestion'
        end
        it 'gets/sets field_type with :field_type' do
            field.field_type = 'project'
            expect(field.field_type).to eq 'project'
        end
        it 'gets/sets id with :id' do
            field.id = '12'
            expect(field.id).to eq '12'
        end
        it 'gets/sets include_on_info with :include_on_info' do
            field.include_on_info = '1'
            expect(field.include_on_info).to eq '1'
        end
        it 'gets/sets include_on_search with :include_on_search' do
            field.include_on_search = '1'
            expect(field.include_on_search).to eq '1'
        end
        it 'gets/sets name with :name' do
            field.name = 'RSpecTest'
            expect(field.name).to eq 'RSpecTest'
        end
        it 'gets/sets protected with :protected' do
            field.protected = '1'
            expect(field.protected).to eq '1'
        end
        it 'gets/sets built_in with :built_in' do
            field.built_in = '0'
            expect(field.built_in).to eq '0'
        end
        it 'gets/sets field_lookup_strings with :field_lookup_strings' do
            data = {
                'id' => '1',
                'value' => 'RSpecTest',
                'display_order' => '3'
            }
            field.field_lookup_strings << FieldLookupStrings.new(data)
            expect(field.field_lookup_strings.first.value).to eq 'RSpecTest'
        end
    end
    describe '#json' do
        it 'becomes json' do
            expect(field.json.is_a?(Hash)).to be true
        end
    end
end