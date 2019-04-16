require_relative 'spec_helper'
require_relative '../lib/Nouns/Albums'
require_relative '../lib/Nouns/NestedGroupItems'
require_relative '../lib/Nouns/NestedFileItems'
require_relative '../lib/Nouns/NestedUserItems'

RSpec.describe Albums do
    describe 'attributes' do
        it 'sets/gets all_users_can_modify with :all_users_can_modify' do
            subject.all_users_can_modify = '1'
            expect(subject.all_users_can_modify).to eq '1'
        end
        it 'sets/gets can_modify with :can_modify' do
            subject.can_modify = '1'
            expect(subject.can_modify).to eq '1'
        end
        it 'sets/gets code with :code' do
            subject.code = 'Testsubject'
            expect(subject.code).to eq 'Testsubject'
        end
        it 'sets/gets company_subject with :company_subject' do
            subject.company_subject = '1'
            expect(subject.company_subject).to eq '1'
        end
        it 'gets/sets approved_company_subject with :approved_company_subject' do
            subject.approved_company_subject = '1'
            expect(subject.approved_company_subject).to eq '1'
        end
        it 'gets/sets created_date with :created_date' do
            subject.created = '19840917000000'
            expect(subject.created).to eq '19840917000000'
        end
        it 'gets/sets id with :id' do
            subject.id = '10'
            expect(subject.id).to eq '10'
        end
        it 'get/sets locked with :locked' do
            subject.locked = '1'
            expect(subject.locked).to eq '1'
        end
        it 'gets/sets my_subject with :my_subject' do
            subject.my_subject = '1'
            expect(subject.my_subject).to eq '1'
        end
        it 'gets/sets name with :name' do
            subject.name = 'RSpecTest'
            expect(subject.name).to eq 'RSpecTest'
        end
        it 'gets/sets private_image_count with :private_image_count' do
            subject.private_image_count = '17'
            expect(subject.private_image_count).to eq '17'
        end
        it 'gets/sets public_image_count with :public_image_count' do
            subject.public_image_count = '17'
            expect(subject.public_image_count).to eq '17'
        end
        it 'gets/sets share_with_all_users wtih :share_with_all_users' do
            subject.share_with_all_users = '1'
            expect(subject.share_with_all_users).to eq '1'
        end
        it 'get/sets shared with :shared' do
            subject.shared = '1'
            expect(subject.shared).to eq '1'
        end
        it 'gets/sets unapproved_image_count with :unapproved_image_count' do
            subject.unapproved_image_count = '9'
            expect(subject.unapproved_image_count).to eq '9'
        end
        it 'gets/sets updated with :updated' do
            time_now = Helpers.fourteen_digit_timestamp()
            subject.updated = time_now
            expect(subject.updated).to eq time_now
        end
        it 'gets/sets user_id with :user_id' do
            subject.user_id = '9'
            expect(subject.user_id).to eq '9'
        end
        it 'gets/set nested files with :files' do
            subject.files << NestedFileItems.new('1','123')
            expect(subject.files.first.id).to eq 123
        end
        it 'gets/sets nested groups with :groups' do
            subject.groups << NestedGroupItems.new('1','9')
            expect(subject.groups.first.id).to eq 9
        end
        it 'gets/sets nested users with :user' do
            subject.users << NestedUserItems.new('1','9')
            expect(subject.users.first.id).to eq 9
        end
    end
    it_behaves_like 'a json builder'
end