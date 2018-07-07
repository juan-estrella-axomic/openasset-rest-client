require_relative 'spec_helper'
require_relative '../lib/Nouns/Categories'

RSpec.describe Categories do
    describe 'attributes' do
        it 'gets/sets alive with :alive' do
            subject.alive = '1'
            expect(subject.alive).to eq '1'
        end
        it 'gets/sets code with :code' do
            subject.code = 'RSpecTest'
            expect(subject.code).to eq 'RSpecTest'
        end
        it 'gets/sets default_access_level with :default_access_level' do
            subject.default_access_level = '1'
            expect(subject.default_access_level).to eq '1'
        end
        it 'gets/sets default_rank with :default_rank' do
            subject.default_rank = '5'
            expect(subject.default_rank).to eq '5'
        end
        it 'gets/sets description with :description' do
            subject.description = 'RSpecTest'
            expect(subject.description).to eq 'RSpecTest'
        end
        it 'gets/sets display_order with :display_order' do
            subject.display_order = '7'
            expect(subject.display_order).to eq '7'
        end
        it 'gets/sets id with :id' do
            subject.id = '10'
            expect(subject.id).to eq '10'
        end
        it 'gets/gets name with :name' do
            subject.name = 'RSpecTest'
            expect(subject.name).to eq 'RSpecTest'
        end
        it 'gets/sets projects_categoy with :projects_subject' do
            subject.projects_subject = '1'
            expect(subject.projects_subject).to eq '1'
        end
    end
    it_behaves_like 'a json builder'
end