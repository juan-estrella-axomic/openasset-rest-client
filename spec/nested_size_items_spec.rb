require_relative 'spec_helper'
require_relative '../lib/Nouns/NestedSizeItems'

RSpec.describe NestedSizeItems do
    describe 'attributes' do
        it 'gets/sets width with :width' do
            
        end
        it 'gets/sets cropped with :cropped' do

        end
        it 'gets/sets watermarked with :watermarked' do

        end
        it 'gets/sets relative_path with :relative_path' do

        end
        it 'gets/sets y_resolution with :y_resolution' do

        end
        it 'gets/sets allow_use with :allow_user' do

        end
        it 'gets/sets id with :id' do
            subject.id = '111'
            expect(subject.id).to eq '111'
        end
        it 'gets/sets http_relative_path with :http_relative_path' do

        end
        it 'gets/sets quality with :quality' do

        end
        it 'gets/sets unc_root with :unc_root' do

        end
        it 'gets/sets colourspace with :colourspace' do

        end
        it 'gets/sets height with :height' do

        end
        it 'gets/sets http_root with :http_root' do

        end
        it 'gets/sets x_resolution with :x_resolution' do

        end
        it 'gets/sets filesize with :filesize' do

        end
        it 'gets/sets recreate with :recreate' do

        end
        it 'gets/sets file_format with :file_format' do

        end
    end
    it_behaves_like 'a json builder'
end