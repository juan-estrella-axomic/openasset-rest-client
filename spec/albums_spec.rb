require_relative 'spec_helper'
require_relative '../lib/Nouns/Albums'
require_relative '../lib/Nouns/NestedGroupItems'
require_relative '../lib/Nouns/NestedFileItems'
require_relative '../lib/Nouns/NestedUserItems'

RSpec.describe Albums do
    let(:album) { Albums.new }
    describe '#all_users_can_modify' do
        it 'can be modified by all users' do
            album.all_users_can_modify = '1'
            expect(album.all_users_can_modify).to eq '1'
        end
    end
    describe '#can_modify' do
        it 'can be modified' do
            album.can_modify = '1'
            expect(album.can_modify).to eq '1'
        end
    end
    describe '#code' do
        it 'has a code' do
            album.code = 'TestAlbum'
            expect(album.code).to eq 'TestAlbum'
        end
    end
    describe '#company_album' do
        it 'is a company album' do
            album.company_album = '1'
            expect(album.company_album).to eq '1'
        end
    end
    describe '#approved_company_album' do
        it 'is an approved company album' do
            album.approved_company_album = '1'
            expect(album.approved_company_album).to eq '1'
        end
    end
    describe '#created' do
        it 'has a created date' do
            album.created = '19840917000000'
            expect(album.created).to eq '19840917000000'
        end
    end
    describe '#id' do
        it 'has an id' do
            album.id = '10'
            expect(album.id).to eq '10'
        end
    end
    describe '#locked' do
        it 'is locked' do
            album.locked = '1'
            expect(album.locked).to eq '1'
        end
    end
    describe '#my_album' do
        it 'is my album' do
            album.my_album = '1'
            expect(album.my_album).to eq '1'
        end
    end
    describe '#name' do
        it 'has a name' do
            album.name = 'RSpecTest'
            expect(album.name).to eq 'RSpecTest'
        end
    end
    describe '#private_image_count' do
        it 'has private image count' do
            album.private_image_count = '17'
            expect(album.private_image_count).to eq '17'
        end
    end
    describe '#public_image_count' do
        it 'has public image count' do
            album.public_image_count = '17'
            expect(album.public_image_count).to eq '17'
        end
    end
    describe '#share_with_all_users' do
        it 'is shared with all users' do
            album.share_with_all_users = '1'
            expect(album.share_with_all_users).to eq '1'
        end
    end
    describe '#shared' do
        it 'is shared' do
            album.shared = '1'
            expect(album.shared).to eq '1'
        end
    end
    describe 'unapproved_image_count' do
        it 'has unapproved images' do
            album.unapproved_image_count = '9'
            expect(album.unapproved_image_count).to eq '9'
        end
    end
    describe '#updated' do
        it 'was updated now' do
            time_now = Helpers.fourteen_digit_timestamp()
            album.updated = time_now
            expect(album.updated).to eq time_now
        end
    end
    describe '#user_id' do
        it 'has a the owners user id' do
            album.user_id = '9'
            expect(album.user_id).to eq '9'
        end
    end
    describe '#files' do
        it 'has a image in it' do
            album.files << NestedFileItems.new('1','123')
            expect(album.files.first.id).to eq '123'
        end
    end
    describe '#groups' do
        it 'accessible to a group' do
            album.groups << NestedGroupItems.new('1','9')
            expect(album.groups.first.id).to eq '9'
        end
    end
    describe '#users' do
        it 'is accessible to a user' do
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