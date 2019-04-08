require_relative 'spec_helper'
require_relative '../lib/SQLParser'
require_relative '../lib/HTTPQueryBuilderHelper'
require_relative '../lib/Nouns/Files'

RSpec.describe HTTPQueryBuilderHelper do
    before(:all) do
        @sql_parser = SQLParser.new
        @resource_type = 'Files'
    end

    it 'creates a parameter for a specific value' do
        str = 'where id = 20'
        exp = @sql_parser.parse(str,@resource_type)
        expect(subject.build_query(exp).options).to eq '?id=20&limit=0'
    end

    it 'creates a parameter for <=' do
        str = 'where id <= 20'
        exp = @sql_parser.parse(str,@resource_type)
        expect(subject.build_query(exp).options).to eq '?id=<=20&limit=0'
    end

    it 'creates a parameter for >=' do
        str = 'where id >= 20'
        exp = @sql_parser.parse(str,@resource_type)
        expect(subject.build_query(exp).options).to eq '?id=>=20&limit=0'
    end

    it 'creates multiple search parameters' do
        str = 'where id = 20 and filename = "test.jpg"'
        exp = @sql_parser.parse(str,@resource_type)
        expect(subject.build_query(exp).options).to eq '?id=20&filename=test.jpg&limit=0'
    end

    it 'creates a negated parameter for a specific value' do
        str = 'where id != 20'
        exp = @sql_parser.parse(str,@resource_type)
        expect(subject.build_query(exp).options).to eq '?id=!20&limit=0'
    end

    it 'creates a range' do
        str = 'where id between 10 and 20'
        exp = @sql_parser.parse(str,@resource_type)
        expect(subject.build_query(exp).options).to eq '?id=10-20&limit=0'
    end

    it 'creates a parameter with a list of values' do
        str = 'where id in (1,2,3,4,5,6)'
        exp = @sql_parser.parse(str,@resource_type)
        expect(subject.build_query(exp).options).to eq '?id=1,2,3,4,5,6&limit=0'
    end

    it 'handles sql "like" clauses WITH sql regex characters' do
        str = 'where filename like "%beach%"'
        exp = @sql_parser.parse(str,@resource_type)
        expect(subject.build_query(exp).options).to eq '?filename=beach&textMatching=contains&limit=0'
    end

    it 'handles sql "like" clauses WITHOUT sql regex characters' do
        str = 'where filename like "beach"'
        exp = @sql_parser.parse(str,@resource_type)
        expect(subject.build_query(exp).options).to eq '?filename=beach&textMatching=exact&limit=0'
    end

    it 'handles sql "not like" clauses WITH sql regex characters' do
        str = 'where filename not like "%beach%"'
        exp = @sql_parser.parse(str,@resource_type)
        expect(subject.build_query(exp).options).to eq '?filename=!beach&textMatching=contains&limit=0'
    end

    it 'handles sql "not like" clauses WITHOUT sql regex characters' do
        str = 'where filename not like "beach"'
        exp = @sql_parser.parse(str,@resource_type)
        expect(subject.build_query(exp).options).to eq '?filename=!beach&textMatching=exact&limit=0'
    end

    it 'does not support "not in" clause' do
        str = 'where id not in (1,2,3,4,5,6)'
        exp = @sql_parser.parse(str,@resource_type)
        begin
            abort_captured = false
            subject.build_query(exp)
        rescue SystemExit => e
            abort_captured = true
        ensure
            expect(abort_captured).to eq true
        end
    end

    it 'does not support "or" clause' do
        str = "where id = 10 or id = 20"
        exp = @sql_parser.parse(str,@resource_type)
        begin
            abort_captured = false
            subject.build_query(exp)
        rescue SystemExit => e
            abort_captured = true
        ensure
            expect(abort_captured).to eq true
        end
    end
end