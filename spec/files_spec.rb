require_relative 'spec_helper'
require_relative '../lib/Nouns/Files'
require_relative '../lib/NestedKeywordItems'
require_relative '../lib/NestedFieldItems'
require_relative '../lib/NestedSizeItems'
require_relative '../lib/NestedAlbumItems'

RSpec.describe Files do
    let(:file) { Files.new }
    it 'has an access level' do
        file.access_level = '1'
        expect(file.access_level).to eq '1'
    end
    it 'has an alternate store id' do
        file.alternate_store_id = '2'
        expect(file.alternate_store_id).to eq '2'
    end
    it 'has a caption' do
        file.caption = 'RSpecTest'
        expect(file.caption).to eq 'RSpecTest'
    end
    it 'has a category id' do
        file.category_id = '1'
        expect(file.category_id).to eq '1'
    end
    it 'has a click count' do
        file.click_count = '23'
        expect(file.click_count).to eq '23'
    end
    it 'does not contain audio' do
        file.contains_audio = '0'
        expect(file.contains_audio).to eq '0'
    end
    it 'does contains video' do
        file.contains_video = '0'
        expect(file.contains_video).to eq '0'
    end
    it 'has a copyright holder' do
        file.copyright_holder_id = '2'
        expect(file.copyright_holder_id).to eq '2'
    end
    it 'has a created date' do
        file.created = '20060409024500'
        expect(file.created).to eq '20060409024500'
    end
    it 'has a description' do
        file.description = 'RSpecTest'
        expect(file.description).to eq 'RSpecTest'
    end
    it 'has a download count' do
        file.download_count = '15'
        expect(file.download_count).to eq '15'
    end
    it 'has a duration' do
        file.duration = '120'
        expect(file.duration).to eq '120'
    end
    it 'has a filename' do
        file.filename = 'RSpecTest'
        expect(file.filename).to eq 'RSpecTest'
    end
    it 'has an id' do
        file.id = '2006'
        expect(file.id).to eq '2006'
    end
    it 'has an md5 at upload' do
        file.md5_at_upload = '695300b39fdfae8db8edb7b1a6ca7993'
        expect(file.md5_at_upload).to eq '695300b39fdfae8db8edb7b1a6ca7993'
    end
    it 'has a current md5' do
        file.md5_now = '695300b39fdfae8db8edb7b1a6ca7993'
        expect(file.md5_now).to eq '695300b39fdfae8db8edb7b1a6ca7993'
    end
    it 'has an original filename' do
        file.original_filename = 'RSpecTest'
        expect(file.original_filename).to eq 'RSpecTest'
    end
    it 'has a photographer' do
        file.photographer_id = '9'
        expect(file.photographer_id).to eq '9'
    end
    it 'has processing two failures' do
        file.processing_failures = '2'
        expect(file.processing_failures).to eq '2'
    end
    it 'is part of a project' do
        file.project_id = '4'
        expect(file.project_id).to eq '4'
    end
    it 'has a rank' do
        file.rank = '5'
        expect(file.rank).to eq '5'
    end
    it 'has a recheck flag' do
        file.recheck = '0'
        expect(file.recheck).to eq '0'
    end
    it 'was replaced' do
        time_now = Helpers.fourteen_digit_timestamp()
        file.replaced = time_now
        expect(file.replaced).to eq time_now
    end
    it 'identifies user who replaced file' do
        file.replaced_user_id = '3'
        expect(file.replaced_user_id).to eq '3'
    end
    it 'has a rotated since upload field' do
        file.rotation_since_upload = '0'
        expect(file.rotation_since_upload).to eq '0'
    end
    it 'has the date uploaded' do
        time_now = Helpers.fourteen_digit_timestamp()
        file.uploaded = time_now
        expect(file.uploaded).to eq time_now
    end
    it 'identifies the user who uploaded the file' do
        file.user_id = '3'
        expect(file.user_id).to eq '3'
    end
    it 'has a rotate degrees field' do
        file.rotate_degrees = '0'
        expect(file.rotate_degrees).to eq '0'
    end
    it 'has the date updated' do
        time_now = Helpers.fourteen_digit_timestamp()
        file.updated = time_now
        expect(file.updated).to eq time_now
    end
    it 'has a video frames per second field' do
        file.video_frames_per_second = '0'
        expect(file.video_frames_per_second).to eq '0'
    end
    it 'has nested keywords' do
        file.keywords << NestedKeywordItems.new('12')
        expect(file.keywords.first.id).to eq '12'
    end
    it 'has nested fields' do
        file.fields << NestedFieldItems.new('6','RSpecTest')
        expect(file.fields.first.values.first).to eq 'RSpecTest'
    end
    it 'has nested sizes' do
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
    it 'has nested albums' do
        file.albums << NestedAlbumItems.new('456')
        expect(file.albums.first.id).to eq '456'
    end
    it 'becomes json' do
        expect(file.json.is_a(Hash)).to be true
    end
end