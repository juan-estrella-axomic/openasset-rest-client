require_relative 'spec_helper'
require_relative '../lib/Nouns/ProjectKeywords'

RSpec.describe ProjectKeywords do
    describe 'attributes' do
        it 'gets/sets id with :id' do
            subject.id = '1'
            expect(subject.id).to eq '1'
        end
        it 'get/sets name with :name' do
            subject.name = 'RSpecTest'
            expect(subject.name).to eq 'RSpecTest'
        end
        it 'gets/sets project_count with :project_count' do
            subject.project_count = '22'
            expect(subject.project_count).to eq '22'
        end
        it 'gets/sets project_keyword_category_id with :project_keyword_category_id' do
            subject.project_keyword_category_id = '4'
            expect(subject.project_keyword_category_id).to eq '4'
        end
    end
    it_behaves_like 'a json builder'
end