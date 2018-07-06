require_relative 'spec_helper'
require_relative '../lib/Nouns/Albums'
require_relative '../lib/Nouns/NestedGroupItems'
require_relative '../lib/Nouns/NestedFileItems'
require_relative '../lib/Nouns/NestedUserItems'

RSpec.describe Albums do
    let(:album) { Albums.new }
    describe 'attributes' do
        it 'sets/gets all_users_can_modify with :all_users_can_modify' do
            album.all_users_can_modify = '1'
            expect(album.all_users_can_modify).to eq '1'
        end
        it 'sets/gets can_modify with :can_modify' do
            album.can_modify = '1'
            expect(album.can_modify).to eq '1'
        end
        it 'sets/gets code with :code' do
            album.code = 'TestAlbum'
            expect(album.code).to eq 'TestAlbum'
        end
        it 'sets/gets company_album with :company_album' do
            album.company_album = '1'
            expect(album.company_album).to eq '1'
        end
        it 'gets/sets approved_company_album with :approved_company_album' do
            album.approved_company_album = '1'
            expect(album.approved_company_album).to eq '1'
        end
        it 'gets/sets created_date with :created_date' do
            album.created = '19840917000000'
            expect(album.created).to eq '19840917000000'
        end
        it 'gets/sets id with :id' do
            album.id = '10'
            expect(album.id).to eq '10'
        end
        it 'get/sets locked with :locked' do
            album.locked = '1'
            expect(album.locked).to eq '1'
        end
        it 'gets/sets my_album with :my_album' do
            album.my_album = '1'
            expect(album.my_album).to eq '1'
        end
        it 'gets/sets name with :name' do
            album.name = 'RSpecTest'
            expect(album.name).to eq 'RSpecTest'
        end
        it 'gets/sets private_image_count with :private_image_count' do
            album.private_image_count = '17'
            expect(album.private_image_count).to eq '17'
        end
        it 'gets/sets public_image_count with :public_image_count' do
            album.public_image_count = '17'
            expect(album.public_image_count).to eq '17'
        end
        it 'gets/sets share_with_all_users wtih :share_with_all_users' do
            album.share_with_all_users = '1'
            expect(album.share_with_all_users).to eq '1'
        end
        it 'get/sets shared with :shared' do
            album.shared = '1'
            expect(album.shared).to eq '1'
        end
        it 'gets/sets unapproved_image_count with :unapproved_image_count' do
            album.unapproved_image_count = '9'
            expect(album.unapproved_image_count).to eq '9'
        end
        it 'gets/sets updated with :updated' do
            time_now = Helpers.fourteen_digit_timestamp()
            album.updated = time_now
            expect(album.updated).to eq time_now
        end
        it 'gets/sets user_id with :user_id' do
            album.user_id = '9'
            expect(album.user_id).to eq '9'
        end
        it 'gets/set nested files with :files' do
            album.files << NestedFileItems.new('1','123')
            expect(album.files.first.id).to eq '123'
        end
        it 'gets/sets nested groups with :groups' do
            album.groups << NestedGroupItems.new('1','9')
            expect(album.groups.first.id).to eq '9'
        end
        it 'gets/sets nested users with :user' do
            album.users << NestedUserItems.new('1','9')
            expect(album.users.first.id).to eq '9'
        end
    end
    describe '#json' do
        it 'converts the object to json' do
            expect(album.json.is_a?(Hash)).to be true
        end
    end
end