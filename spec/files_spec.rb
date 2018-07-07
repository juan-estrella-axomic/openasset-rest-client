require_relative 'spec_helper'
require_relative '../lib/Nouns/Files'
require_relative '../lib/Nouns/NestedKeywordItems'
require_relative '../lib/Nouns/NestedFieldItems'
require_relative '../lib/Nouns/NestedSizeItems'
require_relative '../lib/Nouns/NestedAlbumItems'

RSpec.describe Files do
    describe 'attributes' do 
        it 'gets/sets access_level with :access_level' do
            subject.access_level = '1'
            expect(subject.access_level).to eq '1'
        end
        it 'gets/sets alternate_store id with :alternate_store_id' do
            subject.alternate_store_id = '2'
            expect(subject.alternate_store_id).to eq '2'
        end
        it 'gets/sets caption with :caption' do
            subject.caption = 'RSpecTest'
            expect(subject.caption).to eq 'RSpecTest'
        end
        it 'gets/sets category_id with :category_id' do
            subject.category_id = '1'
            expect(subject.category_id).to eq '1'
        end
        it 'gets/sets click count with :click_count' do
            subject.click_count = '23'
            expect(subject.click_count).to eq '23'
        end
        it 'gets/sets contains_audio with :coontains_audio' do
            subject.contains_audio = '0'
            expect(subject.contains_audio).to eq '0'
        end
        it 'gets/sets contains_video with :contains_video' do
            subject.contains_video = '0'
            expect(subject.contains_video).to eq '0'
        end
        it 'gets/sets copyright_holder_id with :copyright_holder_id' do
            subject.copyright_holder_id = '2'
            expect(subject.copyright_holder_id).to eq '2'
        end
        it 'gets/sets created_date with :created_date' do
            subject.created = '20060409024500'
            expect(subject.created).to eq '20060409024500'
        end
        it 'gets/sets description with :description' do
            subject.description = 'RSpecTest'
            expect(subject.description).to eq 'RSpecTest'
        end
        it 'gets/sets download count with :download_count' do
            subject.download_count = '15'
            expect(subject.download_count).to eq '15'
        end
        it 'gets/sets duration with :duration' do
            subject.duration = '120'
            expect(subject.duration).to eq '120'
        end
        it 'gets/sets subjectname with :subjectname' do
            subject.subjectname = 'RSpecTest'
            expect(subject.subjectname).to eq 'RSpecTest'
        end
        it 'gets/sets id with :id' do
            subject.id = '2006'
            expect(subject.id).to eq '2006'
        end
        it 'gets/sets md5_at_upload with :md5_at_upload' do
            subject.md5_at_upload = '695300b39fdfae8db8edb7b1a6ca7993'
            expect(subject.md5_at_upload).to eq '695300b39fdfae8db8edb7b1a6ca7993'
        end
        it 'gets/sets md5_now with :md5_now' do
            subject.md5_now = '695300b39fdfae8db8edb7b1a6ca7993'
            expect(subject.md5_now).to eq '695300b39fdfae8db8edb7b1a6ca7993'
        end
        it 'get/sets original_subjectname with :original_subjectname' do
            subject.original_subjectname = 'RSpecTest'
            expect(subject.original_subjectname).to eq 'RSpecTest'
        end
        it 'gets/sets photographer with :photographer' do
            subject.photographer_id = '9'
            expect(subject.photographer_id).to eq '9'
        end
        it 'gets/sets processing_failures with :processing_failures' do
            subject.processing_failures = '2'
            expect(subject.processing_failures).to eq '2'
        end
        it 'gets/sets project_id with :project_id' do
            subject.project_id = '4'
            expect(subject.project_id).to eq '4'
        end
        it 'gets/sets rank with :rank' do
            subject.rank = '5'
            expect(subject.rank).to eq '5'
        end
        it 'gets/sets recheck with :recheck' do
            subject.recheck = '0'
            expect(subject.recheck).to eq '0'
        end
        it 'gets/sets replaced with :replaced' do
            time_now = Helpers.fourteen_digit_timestamp()
            subject.replaced = time_now
            expect(subject.replaced).to eq time_now
        end
        it 'gets/sets replaced_user_id with :replaced_user_id' do
            subject.replaced_user_id = '3'
            expect(subject.replaced_user_id).to eq '3'
        end
        it 'gets/sets rotation_since_upload with :rotation_since_upload' do
            subject.rotation_since_upload = '0'
            expect(subject.rotation_since_upload).to eq '0'
        end
        it 'gets/sets uploaded with :uploaded' do
            time_now = Helpers.fourteen_digit_timestamp()
            subject.uploaded = time_now
            expect(subject.uploaded).to eq time_now
        end
        it 'gets/sets user_id with :user_id' do
            subject.user_id = '3'
            expect(subject.user_id).to eq '3'
        end
        it 'gets/sets rotate_degrees with :rotate_degrees' do
            subject.rotate_degrees = '0'
            expect(subject.rotate_degrees).to eq '0'
        end
        it 'gets/sets updated with :updated' do
            time_now = Helpers.fourteen_digit_timestamp()
            subject.updated = time_now
            expect(subject.updated).to eq time_now
        end
        it 'gets/sets video_frames_per_second with :video_frames_per_second' do
            subject.video_frames_per_second = '0'
            expect(subject.video_frames_per_second).to eq '0'
        end
        it 'gets/sets keywords with :keywords' do
            subject.keywords << NestedKeywordItems.new('12')
            expect(subject.keywords.first.id).to eq '12'
        end
        it 'gets/sets fields with :fields' do
            subject.fields << NestedFieldItems.new('6','RSpecTest')
            expect(subject.fields.first.values.first).to eq 'RSpecTest'
        end
        it 'gets/sets sizes with :sizes' do
            data = {
                'subjectsize' => '8554247',
                'x_resolution' => '300',
                'height' => '3000',
                'y_resolution' => '300',
                'quality' => '0',
                'colourspace' => 'RGB',
                'cropped' => '0',
                'subject_format' => 'jpg',
                'unc_root' => '//data.openasset.com/3f741c2e/',
                'recreate' => '0',
                'allow_use': 1,
                'http_root' => '//data.openasset.com/3f741c2e/',
                'http_relative_path' => 'fa98252f0eddf54b3e5ae105a76c8073/50_7053_000.jpg',
                'relative_path' => 'fa98252f0eddf54b3e5ae105a76c8073/50_7053_000.jpg',
                'id' => '1',
                'watermarked' => '',
                'width' => '2252'
            }
            subject.sizes << NestedSizeItems.new(data)
            expect(subject.sizes.first.id).to eq '1'
        end
        it 'gets/sets albums with :albums' do
            subject.albums << NestedAlbumItems.new('456')
            expect(subject.albums.first.id).to eq '456'
        end
    end
    it_behaves_like 'a json builder'
end