require_relative 'spec_helper'
require_relative '../lib/Nouns/TextRewrites'

RSpec.describe TextRewrites do
    describe 'attributes' do
        it 'gets/sets case_sensitive with :case_sensitive' do
            subject.case_sensitive = '1'
            expect(subject.case_sensitive).to eq '1'
        end
        it 'gets/sets id with :id' do
            subject.id = '10'
            expect(subject.id).to eq '10'
        end
        it 'gets/sets preserve_first_letter_case with :preserve_first_letter_case' do
            subject.preserve_first_letter_case = '1'
            expect(subject.preserve_first_letter_case).to eq '1'
        end
        it 'gets/sets text_match with :text_match' do
            subject.text_match = 'Old Value'
            expect(subject.text_match).to eq 'Old Value'
        end
        it 'gets/sets text_replace with :text_replace' do
            subject.text_replace = 'New Value'
            expect(subject.text_replace).to eq 'New Value'
        end
    end
    it_behaves_like 'a json builder'
end