require_relative 'spec_helper'
require_relative '../lib/Nouns/Fields'

RSpec.describe Fields do
    let(:field) { Fields.new }
    it 'is alive' do
        field.alive = '1'
        expect(field.alive).to eq '1'
    end
    it 'has a cadinality value' do
        field.cardinality = '1'
        expect(field.id).to eq '1'
    end
    it 'has a code' do
        field.code = 'MarketingDescription'
        expect(field.code).to eq 'MarketingDescription'
    end
    ir 'has a rest code' do
        field.rest_code = 'marketing_description'
        expect(field.rest_code).to eq 'marketing_description'
    end
    it 'has a descripton' do
        field.description = 'RSpecTest'
        expect(field.description).to eq 'RSpecTest'
    end
    it 'has a display order' do
        field.display_order = '5'
        expect(field.display_order).to eq '5'
    end
    it 'has a field display type' do
        field.field_display_type = 'suggestion'
        expect(field.field_display_type).to eq 'suggestion'
    end
    it 'is a project field' do
        field.field_type = 'project'
        expect(field.field_type).to eq 'project'
    end
    it 'has an id' do
        field.id = '12'
        expect(field.id).to eq '12'
    end
    it 'is included in info' do
        field.included_in_info = '1'
        expect(field.included_in_info).to eq '1'
    end
    it 'is included in searches' do
        field.included_in_info = '1'
        expect(field.included_in_info).to eq '1'
    end
    it 'has a name' do
        field.name = 'RSpecTest'
        expect(field.name).to eq 'RSpecTest'
    end
    it 'is protected' do
        field.protected = '1'
        expect(field.protected).to eq '1'
    end
    it 'is not a build in field' do
        field.built_in = '0'
        expect(field.built_in).to eq '0'
    end
    it 'has field lookup string values' do
        data = {
            'id' => '1',
            'value' => 'RSpecTest',
            'display_order' => '3'
        }
        field.field_lookup_strings << FieldLookupString.new(data)
        expect(field.field_lookup_strings.first.value).to eq 'RSpecTest'
    end
    it 'becomes json' do
        expect(field.json.is_a(Hash)).to be true
    end
end