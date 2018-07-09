require_relative 'spec_helper'
require_relative '../lib/Nouns/Searches'
require_relative '../lib/Nouns/SearchItems'
require_relative '../lib/Nouns/Groups'
require_relative '../lib/Nouns/Users'

RSpec.describe Searches do
    describe 'attirbutes' do
        it 'gets/sets all_users_can_modify with :all_users_can_modify' do
            subject.all_users_can_modify = '1'
            expect(subject.all_users_can_modify).to eq '1'
        end
        it 'gets/sets approved_company_search with :approved_company_search' do
            subject.approved_company_search = '1'
            expect(subject.approved_company_search).to eq '1'
        end
        it 'gets/sets can_modify with :can_modify' do
            subject.can_modify = '1'
            expect(subject.can_modify).to eq '1'
        end
        it 'gets/sets code with :code' do
            subject.code = '1df7c4d00d4fef40203d0f2010a3bb38'
            expect(subject.code).to eq '1df7c4d00d4fef40203d0f2010a3bb38'
        end
        it 'gets/sets company_saved_search with :company_saved_search' do
            subject.company_saved_search = '1'
            expect(subject.company_saved_search).to eq '1'
        end
        it 'gets/sets created with :created' do
            time = Helpers.current_time_in_milliseconds()
            subject.created = time
            expect(subject.created).to eq time
        end
        it 'gets/sets id with :id' do
            subject.id = '111'
            expect(subject.id).to eq '111'
        end
        it 'gets/sets name with :name' do
            subject.name= 'RSpecTest'
            expect(subject.name).to eq 'RSpecTest'
        end
        it 'gets/sets saved with :saved' do
            subject.saved = '1'
            expect(subject.saved).to eq '1'
        end
        it 'gets/sets share_with_all_users with :share_with_all_users' do
            subject.share_with_all_users = '1'
            expect(subject.share_with_all_users).to eq '1'
        end
        it 'gets/sets updated with :updated' do
            time = Helpers.current_time_in_milliseconds()
            subject.updated = time
            expect(subject.updated).to eq time
        end
        it 'gets/sets user_id with :user_id' do
            subject.user_id = '44'
            expect(subject.user_id).to eq '44'
        end
        it 'gets/sets search_items with :search_items' do
            data = {
                'code'     => 'project',
                'exclude'  => '0',
                'operator' => 'OR',
                'ids'      => ['1','2','3']
            }
            search_item = SearchItems.new(data)
            subject.search_items << search_item
            expect(subject.search_items.first.code).to eq 'project'
        end
        it 'gets/sets groups with :groups' do
            subject.groups << NestedGroupItems.new('99')
            expect(subject.groups.first.id).to eq '99'
        end
        it 'gets/sets user with :user' do
            subject.users << NestedUserItems.new('77')
            expect(subject.users.first.id).to eq '77'
        end
    end
    it_behaves_like 'a json builder'
end