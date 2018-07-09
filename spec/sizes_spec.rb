require_relative 'spec_helper'
require_relative '../lib/Nouns/Sizes'

RSpec.describe Sizes do
    describe 'attirbutes' do
        it 'gets/sets alive with :alive' do
            subject.alive = '1'
            expect(subject.alive).to eq '1'
        end
        it 'gets/sets always_create with :always_create' do
            subject.always_create = '1'
            expect(subject.always_create).to eq '1'
        end
        it 'gets/sets colourspace with :colourspace' do
            subject.colourspace = 'RGB'
            expect(subject.colourspace).to eq 'RGB'
        end
        it 'gets/sets crop_to_fit with :crop_to_fit' do
            subject.crop_to_fit = '1'
            expect(subject.crop_to_fit).to eq '1'
        end
        it 'gets/sets description with :description' do
            subject.description = 'Test description'
            expect(subject.description).to eq 'Test description'
        end
        it 'gets/sets display_order with :display_order' do
            subject.display_order = '3'
            expect(subject.display_order).to eq '3'
        end
        it 'gets/sets file_format with :file_format' do
            subject.file_format = 'jpg'
            expect(subject.file_format).to eq 'jpg'
        end
        it 'gets/sets height with :height' do
            subject.height= '1080'
            expect(subject.height).to eq '1080'
        end
        it 'gets/sets id with :id' do
            subject.id = '22'
            expect(subject.id).to eq '22'
        end
        it 'gets/sets name with :name' do
            subject.name = '1'
            expect(subject.name).to eq '1'
        end
        it 'gets/sets original with :original' do
            subject.original = '0'
            expect(subject.original).to eq '0'
        end
        it 'gets/sets postfix with :postfix' do
            subject.postfix = 'small'
            expect(subject.postfix).to eq 'small'
        end
        it 'gets/sets protected with :protected' do
            subject.protected = '1'
            expect(subject.protected).to eq '1'
        end
        it 'gets/sets quality with :quality' do
            subject.quality = '85'
            expect(subject.quality).to eq '85'
        end
        it 'gets/sets size_protected with :size_protected' do
            subject.size_protected = '1'
            expect(subject.size_protected).to eq '1'
        end
        it 'gets/sets use_for_contact_sheet with :use_for_contact_sheet' do
            subject.use_for_contact_sheet = '1'
            expect(subject.use_for_contact_sheet).to eq '1'
        end
        it 'gets/sets use_for_power_point with :use_for_power_point' do
            subject.use_for_power_point = '1'
            expect(subject.use_for_power_point).to eq '1'
        end
        it 'gets/sets use_for_zip with :use_for_zip' do
            subject.use_for_zip = '1'
            expect(subject.use_for_zip).to eq '1'
        end
        it 'gets/sets width with :width' do
            subject.width = '1920'
            expect(subject.width).to eq '1920'
        end
        it 'gets/sets x_resolution with :x_resolution' do
            subject.x_resolution = '72'
            expect(subject.x_resolution).to eq '72'
        end
        it 'gets/sets y_resolution with :y_resolution' do
            subject.y_resolution = '72'
            expect(subject.y_resolution).to eq '72'
        end
    end
    it_behaves_like 'a json builder'
end