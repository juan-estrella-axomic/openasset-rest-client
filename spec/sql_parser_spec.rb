require_relative '../lib/SQLParser.rb'
require_relative '../lib/Nouns/Files.rb'

describe SQLParser do
    describe 'parse' do
        let(:parser) { SQLParser.new }
        it 'handles =' do
            p = parser
            query = "where original_filename = 'flower'"
            expected_result = [["", "original_filename", "==", "flower", ""]]
            expressions = p.parse(query,'Files')
            expect(expressions).to eq expected_result
        end
        it 'handles <>' do
            p = parser
            query = "where original_filename <> 'flower'"
            expected_result = [["", "original_filename", "!=", "flower", ""]]
            expressions = p.parse(query,'Files')
            expect(expressions).to eq expected_result
        end
        it 'handles !=' do
            p = parser
            query = "where original_filename <> 'flower'"
            expected_result = [["", "original_filename", "!=", "flower", ""]]
            expressions = p.parse(query,'Files')
            expect(expressions).to eq expected_result
        end
        it 'handles >' do
            p = parser
            query = "where id > 58"
            expected_result = [["", "id", ">", 58, ""]]
            expressions = p.parse(query,'Files')
            expect(expressions).to eq expected_result
        end
        it 'handles <' do
            p = parser
            query = "where id < 57"
            expected_result = [["", "id", "<", 57, ""]]
            expressions = p.parse(query,'Files')
            expect(expressions).to eq expected_result
        end
        it 'handles >=' do
            p = parser
            query = "where id >= 99"
            expected_result = [["", "id", ">=", 99, ""]]
            expressions = p.parse(query,'Files')
            expect(expressions).to eq expected_result
        end
        it 'handles <=' do
            p = parser
            query = "where id <= 99"
            expected_result = [["", "id", "<=", 99, ""]]
            expressions = p.parse(query,'Files')
            expect(expressions).to eq expected_result
        end
        it 'handles between' do
            p = parser
            query = "where id between 1 and 99"
            expected_result = [["", "id", "between", ["1", "99"], ""]]
            expressions = p.parse(query,'Files')
            expect(expressions).to eq expected_result
        end
        it 'handles like' do
            p = parser
            query = "where original_filename like '%flower%'"
            expected_result = [["", "original_filename", {"regex"=>/^(.*)flower(.*)$/i, "is_regex_negated"=>false}, "%flower%", ""]]
            expressions = p.parse(query,'Files')
            expect(expressions).to eq expected_result
        end
        it 'handles not like' do
            p = parser
            query = "where original_filename not like '%flower%'"
            expected_result = [["", "original_filename", {"regex"=>/^(.*)flower(.*)$/i, "is_regex_negated"=>true}, "%flower%", ""]]
            expressions = p.parse(query,'Files')
            expect(expressions).to eq expected_result
        end
        it 'handles in' do
            p = parser
            query = "where original_filename in ('one','two','three','in')"
            expected_result = [["", "original_filename", "in", ["one", "two", "three", "in"], ""]]
            expressions = p.parse(query,'Files')
            expect(expressions).to eq expected_result
        end
        it 'handles and statements' do
            p = parser
            query = "where original_filename in ('one','two','three','in') and id > 47 "
            expected_result = [["", "original_filename", "in", ["one", "two", "three", "in"], ""], "and", ["", "id", ">", 47, ""]]
            expressions = p.parse(query,'Files')
            expect(expressions).to eq expected_result
        end
        it 'handles or statements' do
            p = parser
            query = "where original_filename in ('one','two','three','in') or id > 47 "
            expected_result = [["", "original_filename", "in", ["one", "two", "three", "in"], ""], "or", ["", "id", ">", 47, ""]]
            expressions = p.parse(query,'Files')
            expect(expressions).to eq expected_result
        end
        it 'retains order of operations' do
            p = parser
            query = "where (original_filename in ('one','two','three','in') or original_filename like '%bummy joe%') and id > 47 "
            expected_result = [["(", "original_filename", "in", ["one", "two", "three", "in"], ""], "or", ["", "original_filename", {"regex"=>/^(.*)bummy joe(.*)$/i, "is_regex_negated"=>false}, "%bummy joe%", ")"], "and", ["", "id", ">", 47, ""]]
            expressions = p.parse(query,'Files')
            expect(expressions).to eq expected_result
        end
        it 'catches mismatched parenthesis' do
            p = parser
            query = "where (original_filename in ('one','two','three','in') or original_filename like '%bummy joe%' and id > 47 "
            expected_result = nil
            expressions = p.parse(query,'Files')
            expect(expressions).to eq expected_result
        end
        it 'catches missing operators' do
            p = parser
            query = "where (original_filename 'flower') and id = 2 "
            expected_result = nil
            expressions = p.parse(query,'Files')
            expect(expressions).to eq expected_result
        end
    end
end
