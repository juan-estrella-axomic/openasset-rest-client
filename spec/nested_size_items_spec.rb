require_relative 'spec_helper'
require_relative '../lib/Nouns/NestedSizeItems'

RSpec.describe NestedSizeItems do
    describe 'attributes' do
        it 'gets/sets width with :width' do
            subject.width = '1920'
            expect(subject.width).to eq '1920'
        end
        it 'gets/sets cropped with :cropped' do
            subject.cropped = '0'
            expect(subject.cropped).to eq '0'
        end
        it 'gets/sets watermarked with :watermarked' do
            subject.watermarked = '0'
            expect(subject.watermarked).to eq '0'
        end
        it 'gets/sets relative_path with :relative_path' do
            subject.relative_path = '87e6262769be90be129b90f178c6c3a3/50_7053_000_N2.jpg'
            expect(subject.relative_path).to eq '87e6262769be90be129b90f178c6c3a3/50_7053_000_N2.jpg'
        end
        it 'gets/sets y_resolution with :y_resolution' do
            subject.y_resolution = '72'
            expect(subject.y_resolution).to eq '72'
        end
        it 'gets/sets allow_use with :allow_use' do
            subject.allow_use = '1'
            expect(subject.allow_use).to eq '1'
        end
        it 'gets/sets id with :id' do
            subject.id = '111'
            expect(subject.id).to eq '111'
        end
        it 'gets/sets http_relative_path with :http_relative_path' do
            subject.http_relative_path = '87e6262769be90be129b90f178c6c3a3/50_7053_000_N2.jpg'
            expect(subject.http_relative_path).to eq '87e6262769be90be129b90f178c6c3a3/50_7053_000_N2.jpg'
        end
        it 'gets/sets quality with :quality' do
            subject.quality = '0'
            expect(subject.quality).to eq '0'
        end
        it 'gets/sets unc_root with :unc_root' do
            subject.unc_root = '//data.openasset.com/3f74567y/'
            expect(subject.unc_root).to eq '//data.openasset.com/3f74567y/'
        end
        it 'gets/sets colourspace with :colourspace' do
            subject.colourspace = 'RGB'
            expect(subject.colourspace).to eq 'RGB'
        end
        it 'gets/sets height with :height' do
            subject.height = '1080'
            expect(subject.height).to eq '1080'
        end
        it 'gets/sets http_root with :http_root' do
            subject.http_root = '//data.openasset.com/3f74567y/'
            expect(subject.http_root).to eq '//data.openasset.com/3f74567y/'
        end
        it 'gets/sets x_resolution with :x_resolution' do
            subject.x_resolution = '72'
            expect(subject.x_resolution).to eq '72'
        end
        it 'gets/sets filesize with :filesize' do
            subject.filesize = '253354'
            expect(subject.filesize).to eq '253354'
        end
        it 'gets/sets recreate with :recreate' do
            subject.recreate = '0'
            expect(subject.recreate).to eq '0'
        end
        it 'gets/sets file_format with :file_format' do
            subject.file_format = 'jpg'
            expect(subject.file_format).to eq 'jpg'
        end
    end
    it_behaves_like 'a json builder'
end