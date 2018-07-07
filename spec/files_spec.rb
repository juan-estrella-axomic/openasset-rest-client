require_relative 'spec_helper'
require_relative '../lib/Nouns/Files'
require_relative '../lib/Nouns/NestedKeywordItems'
require_relative '../lib/Nouns/NestedFieldItems'
require_relative '../lib/Nouns/NestedSizeItems'
require_relative '../lib/Nouns/NestedAlbumItems'

RSpec.describe Files do
    let(:file) { Files.new }
    describe 'attributes' do 
        it 'gets/sets access_level with :access_level' do
            file.access_level = '1'
            expect(file.access_level).to eq '1'
        end
        it 'gets/sets alternate_store id with :alternate_store_id' do
            file.alternate_store_id = '2'
            expect(file.alternate_store_id).to eq '2'
        end
        it 'gets/sets caption with :caption' do
            file.caption = 'RSpecTest'
            expect(file.caption).to eq 'RSpecTest'
        end
        it 'gets/sets category_id with :category_id' do
            file.category_id = '1'
            expect(file.category_id).to eq '1'
        end
        it 'gets/sets click count with :click_count' do
            file.click_count = '23'
            expect(file.click_count).to eq '23'
        end
        it 'gets/sets contains_audio with :coontains_audio' do
            file.contains_audio = '0'
            expect(file.contains_audio).to eq '0'
        end
        it 'gets/sets contains_video with :contains_video' do
            file.contains_video = '0'
            expect(file.contains_video).to eq '0'
        end
        it 'gets/sets copyright_holder_id with :copyright_holder_id' do
            file.copyright_holder_id = '2'
            expect(file.copyright_holder_id).to eq '2'
        end
        it 'gets/sets created_date with :created_date' do
            file.created = '20060409024500'
            expect(file.created).to eq '20060409024500'
        end
        it 'gets/sets description with :description' do
            file.description = 'RSpecTest'
            expect(file.description).to eq 'RSpecTest'
        end
        it 'gets/sets download count with :download_count' do
            file.download_count = '15'
            expect(file.download_count).to eq '15'
        end
        it 'gets/sets duration with :duration' do
            file.duration = '120'
            expect(file.duration).to eq '120'
        end
        it 'gets/sets filename with :filename' do
            file.filename = 'RSpecTest'
            expect(file.filename).to eq 'RSpecTest'
        end
        it 'gets/sets id with :id' do
            file.id = '2006'
            expect(file.id).to eq '2006'
        end
        it 'gets/sets md5_at_upload with :md5_at_upload' do
            file.md5_at_upload = '695300b39fdfae8db8edb7b1a6ca7993'
            expect(file.md5_at_upload).to eq '695300b39fdfae8db8edb7b1a6ca7993'
        end
        it 'gets/sets md5_now with :md5_now' do
            file.md5_now = '695300b39fdfae8db8edb7b1a6ca7993'
            expect(file.md5_now).to eq '695300b39fdfae8db8edb7b1a6ca7993'
        end
        it 'get/sets original_filename with :original_filename' do
            file.original_filename = 'RSpecTest'
            expect(file.original_filename).to eq 'RSpecTest'
        end
        it 'gets/sets photographer with :photographer' do
            file.photographer_id = '9'
            expect(file.photographer_id).to eq '9'
        end
        it 'gets/sets processing_failures with :processing_failures' do
            file.processing_failures = '2'
            expect(file.processing_failures).to eq '2'
        end
        it 'gets/sets project_id with :project_id' do
            file.project_id = '4'
            expect(file.project_id).to eq '4'
        end
        it 'gets/sets rank with :rank' do
            file.rank = '5'
            expect(file.rank).to eq '5'
        end
        it 'gets/sets recheck with :recheck' do
            file.recheck = '0'
            expect(file.recheck).to eq '0'
        end
        it 'gets/sets replaced with :replaced' do
            time_now = Helpers.fourteen_digit_timestamp()
            file.replaced = time_now
            expect(file.replaced).to eq time_now
        end
        it 'gets/sets replaced_user_id with :replaced_user_id' do
            file.replaced_user_id = '3'
            expect(file.replaced_user_id).to eq '3'
        end
        it 'gets/sets rotation_since_upload with :rotation_since_upload' do
            file.rotation_since_upload = '0'
            expect(file.rotation_since_upload).to eq '0'
        end
        it 'gets/sets uploaded with :uploaded' do
            time_now = Helpers.fourteen_digit_timestamp()
            file.uploaded = time_now
            expect(file.uploaded).to eq time_now
        end
        it 'gets/sets user_id with :user_id' do
            file.user_id = '3'
            expect(file.user_id).to eq '3'
        end
        it 'gets/sets rotate_degrees with :rotate_degrees' do
            file.rotate_degrees = '0'
            expect(file.rotate_degrees).to eq '0'
        end
        it 'gets/sets updated with :updated' do
            time_now = Helpers.fourteen_digit_timestamp()
            file.updated = time_now
            expect(file.updated).to eq time_now
        end
        it 'gets/sets video_frames_per_second with :video_frames_per_second' do
            file.video_frames_per_second = '0'
            expect(file.video_frames_per_second).to eq '0'
        end
        it 'gets/sets keywords with :keywords' do
            file.keywords << NestedKeywordItems.new('12')
            expect(file.keywords.first.id).to eq '12'
        end
        it 'gets/sets fields with :fields' do
            file.fields << NestedFieldItems.new('6','RSpecTest')
            expect(file.fields.first.values.first).to eq 'RSpecTest'
        end
        it 'gets/sets sizes with :sizes' do
            data = {
                'filesize' => '8554247',
                'x_resolution' => '300',
                'height' => '3000',
                'y_resolution' => '300',
                'quality' => '0',
                'colourspace' => 'RGB',
                'cropped' => '0',
                'file_format' => 'jpg',
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
            file.sizes << NestedSizeItems.new(data)
            expect(file.sizes.first.id).to eq '1'
        end
        it 'gets/sets albums with :albums' do
            file.albums << NestedAlbumItems.new('456')
            expect(file.albums.first.id).to eq '456'
        end
    end
    describe '#json' do
        it 'converts object to json' do
            expect(file.json.is_a?(Hash)).to be true
        end
    end
end