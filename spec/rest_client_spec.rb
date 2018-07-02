require_relative '../openasset-rest-client'
require 'rspec'

include OpenAsset
include RSpec

describe RestClient do

    let(:client) { RestClient.new('demo-jes.openasset.com','rspec_user','') } 

    context 'when dealing with access levels' do
        it 'retrieves an access level' do
            expect(client.get_access_levels.first.class.to_s).to eq 'AccessLevels'
        end
    end

    context 'when dealing with albums' do
        it 'retrieves an album' do
            expect(client.get_albums.first.class.to_s).to eq 'Albums'
        end
    end

    context 'when dealing with alternate stores' do
        it 'retrieves an alternate store' do
            expect(client.get_alternate_stores.first.class.to_s).to eq 'AlternateStores'
        end
    end

    context 'when dealing with aspect ratios' do
        it 'retrieves an aspect ratio' do
            expect(client.get_aspect_ratios.first.class.to_s).to eq 'AspectRatios'
        end
    end

    context 'when dealing with categories' do
        it 'retrieves a category' do
            expect(client.get_categories.first.class.to_s).to eq 'Categories'
        end
    end

    context 'when dealing with copyright holders' do
        it 'retrieves a copyright holder' do
            expect(client.get_copyright_holders.first.class.to_s).to eq 'CopyrightHolders'
        end
    end

    context 'when dealing with copyright policies' do
        it 'retrieves a copyright policy' do
            expect(client.get_copyright_policies.first.class.to_s).to eq 'CopyrightPolicies'
        end
    end

    context 'when dealing with data integrations' do
        it 'retrieves a data integration' do
            expect(client.get_data_integrations.first.class.to_s).to eq 'DataIntegrations'
        end
    end

    context 'when dealing with fields' do
        it 'retrieves a field' do
            expect(client.get_fields.first.class.to_s).to eq 'Fields'
        end
    end

    context 'when dealing with field lookup strings' do
        it 'retrieves a field lookup string' do
            expect(client.get_field_lookup_strings.first.class.to_s).to eq 'FieldLookupStrings'
        end
    end

    context 'when dealing with files' do
        it 'retrieves a file' do
            expect(client.get_files.first.class.to_s).to eq 'Files'
        end
    end

    context 'when dealing with groups' do
        it 'retrieves a group' do
            expect(client.get_groups.first.class.to_s).to eq 'Groups'
        end
    end

    context 'when dealing with keyword categories' do
        it 'retrieves a keyword category' do
            expect(client.get_categories.first.class.to_s).to eq 'KeywordCategories'
        end
    end

    context 'when dealing with keywords' do
        it 'retrieves a keyword' do
            expect(client.get_keywords.first.class.to_s).to eq 'Keywords'
        end
    end

    context 'when dealing with location' do

    end

    context 'object with nested album' do

    end

    context 'object with nested fields' do

    end 

    context 'user with nested groups' do

    end

    context 'group with nested users' do

    end

    context 'file object with nested keywords' do

    end

    context 'project object with nested keywords' do

    end

    context 'file with nested sizes' do

    end

    context 'when dealing with photographers' do
        it 'retrieves a photographer' do
            expect(client.get_photographers.first.class.to_s).to eq 'Photographers'
        end
    end

    context 'when dealing with project keyword categories' do
        it 'retrieves a project keyword category' do
            expect(client.get_project_keyword_categories.first.class.to_s).to eq 'ProjectKeywordCategies'
        end
    end

    context 'when dealing with project keywords' do
        it 'retrieves a project keyword' do
            expect(client.get_project_keywords.first.class.to_s).to eq 'ProjectKeywords'
        end
    end

    context 'when dealing with projects' do
        it 'retrieves a project' do
            expect(client.get_projects.first.class.to_s).to eq 'Projects'
        end
    end

    context 'when dealing with searches' do
        it 'retrieves a search' do
            expect(client.get_searches.first.class.to_s).to eq 'Searches'
        end
    end

    context 'search object with nested search' do

    end

    context 'when dealing with sizes' do
        it 'retrieves a search' do
            expect(client.get_sizes.first.class.to_s).to eq 'Sizes'
        end
    end

    context 'when dealing with text rewrites' do
        it 'retrieves a text rewrite' do
            expect(client.get_text_rewrites.first.class.to_s).to eq 'TextRewrites'
        end
    end

    context 'when dealing with users' do
        it 'retrieves a user' do
            expect(client.get_users.first.class.to_s).to eq 'users'
        end
    end

end