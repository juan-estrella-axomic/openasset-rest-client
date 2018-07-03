require_relative '../openasset-rest-client'
require 'rspec'

include OpenAsset
include RSpec

describe RestClient do

    let(:client) { RestClient.new('demo-jes.openasset.com','rspec_user','') }
    let(:query) { RestOptions.new }

    #################
    # Access Levels #
    #################
    context 'when dealing with access levels' do
        it 'retrieves an access level' do
            object = client.get_access_levels.first
            expect(object.is_a?(AccessLevels)).to be true
        end
    end

    ##########
    # Albums #
    ##########
    context 'when dealing with albums' do
        it 'retrieves an album' do
            object = client.get_albums.first
            expect(object.is_a?(Albums)).to be true
        end
        it 'creates an album' do
            name = 'RspecTest'
            album = Albums.new(name)
            object = client.create_albums(album,true).first
            expect(object.is_a?(Albums)).to be true
        end
        it 'modifies an album' do
            query.clear
            query.add_option('name','RspecTest')
            query.add_option('textMatching','exact')
            album = client.get_albums(query)
            album.name = 'RspecTest-Updated'
            expect(client.update_albums(album).code).to eq '200'
        end
        it 'deletes an album' do
            query.clear
            query.add_option('name','RspecTest-Updated')
            query.add_option('textMatching','exact')
            album = client.get_albums(query)
            expect(client.delete_albums(album).code).to eq '204'
        end
    end

    ####################
    # Alternate Stores #
    ####################
    context 'when dealing with alternate stores' do
        it 'retrieves an alternate store' do
            object = client.get_alternate_stores.first
            expect(object.is_a?(AlternateStores)).to be true
        end
    end

    ################
    # Apect Ratios #
    ################
    context 'when dealing with aspect ratios' do
        it 'retrieves an aspect ratio' do
            object = client.get_aspect_ratios.first
            expect(object.is_a?(AspectRatios)).to be true
        end
    end

    ##############
    # Categories #
    ##############
    context 'when dealing with categories' do
        it 'retrieves a category' do
            object = get_categories.first
            expect(object.is_a?(Categories)).to be true
        end
        it 'modifies an category' do
            query.clear
            query.add_option('name','Reference')
            query.add_option('textMatching','exact')
            category = client.get_categories(query).first
            category.name = 'Reference-Updated'
            client.update_categories(category)
            query.clear
            query.add_option('name','Reference-Updated')
            query.add_option('textMatching','exact')
            category.name = 'Reference'
            category = client.get_categories(query).first
            expect(client.update_categories(category).code).to eq '200'
        end
    end

    #####################
    # Copyright Holders #
    #####################
    context 'when dealing with copyright holders' do
        it 'creates a copyright holder' do
            copyright_holder = CopyrightHolders.new('RSpecTest')
            object = client.create_copyright_holders(copyright_holder,true)
            expect(object.is_a?(CopyrightHolders)).to be true
        end
        it 'retrieves a copyright holder' do
            object = client.get_copyright_holders.first
            expect(object.is_a?(CopyrightHolders)).to be true
        end
        it 'deletes a copyright holder' do
            query.clear
            query.add_option('name','RSpectTest')
            query.add_option('textMatching','exact')
            copyright_holder = client.get_copyright_holders(query)
            expect(client.delete_copyright_holders(copyright_holder).code).to eq '204'
        end
    end

    #####################
    # Copyright Polices #
    #####################
    context 'when dealing with copyright policies' do
        it 'creates a copyright policy' do
            copyright_policy = CopyrightPolicies.new('RSpecTest')
            object = client.create_copyright_polices(copyright_policy,true).first
            expect(object.is_a?(CopyrightPolicies)).to be true
        end
        it 'retrieves a copyright policy' do
            object = client.get_copyright_policies.first
            expect(object.is_a?(CopyrightHolders)).to be true
        end
        it 'updates a copyright policy' do
            query.clear
            query.add_option('name','RSpecTest')
            query.add_option('textMatching','exact')
            copyright_policy = client.get_copyright_policies(query).first
            copyright_policy.name = 'RSpecTest-Updated'
            expect(client.update_copyright_policies(copyright_policy).code).to eq '200'
        end
        it 'deletes a copyright policy' do
            query.clear
            query.add_option('name','RSpecTest-Updated')
            query.add_option('textMatching','exact')
            copyright_policy = client.get_copyright_policies(query)
            expect(client.delete_copyright_policies(copyright_policy).code).to eq '204'
        end

    end

    #####################
    # Data Integrations #
    #####################
    context 'when dealing with data integrations' do
        it 'retrieves a data integration' do
            object = client.get_data_integrations.first
            expect(object.is_a?(DataIntegrations)).to be true
        end
    end

    ##########
    # Fields #
    ##########
    context 'when dealing with fields' do
        it 'creates a field' do
            field = Fields.new('RSpecTest')
            object = client.create_fields(field,true).first
            expect(object.is_a?(Fields)).to be true
        end
        it 'retrieves a field' do
            object = client.get_fields.first
            expect(object.is_a?(Fields)).to be true
        end
        it 'updates a field' do
            query.clear
            query.add_option('name','RSpecTest')
            query.add_option('textMatching','exact')
            field = client.get_fields(query).first
            field.name = 'RSpecTest-Updated'
            expect(client.update_fields(field).code).to eq '200'
        end
        it 'deletes a field' do
            query.clear
            query.add_option('name','RSpecTest-Updated')
            query.add_option('textMatching','exact')
            field = client.get_fields(query)
            expect(client.delete_fields(field).code).to eq '204'
        end
    end

    ########################
    # Field Lookup Strings #
    ########################
    context 'when dealing with field lookup strings' do
           # g c u d
        it 'creats a field lookup string' do
            field_lookup_string = FieldLookupStrings.new('RSpecTest')
            object = client.create_field_lookup_strings(field_lookup_string,true).first
            expect(object.is_a?(FieldLookupStrings)).to be true
        end
        it 'retrieves a field lookup string' do
            object = client.get_field_lookup_strings.first
            expect(object.is_a?(FieldLookupStrings)).to be true
        end
        it 'updates a field lookup string' do
            query.clear
            query.add_option('name','RSpecTest')
            query.add_option('textMatching','exact')
            field_lookup_string = client.get_field_lookup_strings(query).first
            field_lookup_string.name = 'RSpecTest-Updated'
            expect(client.update_field_lookup_strings(field_lookup_string).code).to eq '200'
        end
        it 'deletes a field lookup string' do
            query.clear
            query.add_option('name','RSpecTest-Updated')
            query.add_option('textMatching','exact')
            field_lookup_string = client.get_field_lookup_strings(query).first
            expect(client.delete_field_lookup_strings(field_lookup_string).code).to eq '204'
        end
    end

    #########
    # Files #
    #########
    context 'when dealing with files' do
        it 'uploads a file' do
            file_path = './resources/rspec_bird.jpg'
            category  = 2 # Reference
            expect(client.upload_file(file_path,category).code).to eq '201'
        end
        context 'retrieves a file' do
            context 'with nested resources' do
                query.clear
                query.add_option('id','11458')
                file = client.get_files(query,true).first
                it 'is a file' do
                    expect(file.is_a?(Files)).to be true
                end
                it 'has sizes' do
                    expect(file.sizes.first.is_a?(NestedSizeItems)).to be true
                end
                it 'has keywords' do
                    expect(file.keywords.first.is_a?(NestedKeywordItems)).to be true
                end
                it 'has fields' do
                    expect(file.fields.first.is_a?(NestedFieldItems)).to be true
                end
            end
        end
        it 'replaces a file' do
            query.clear
            query.add_option('original_filename','rspec_bird.jpg')
            query.add_option('textMatching','exact')
            existing_img = client.get_files(query).first
            replacement_img = './resources/rspec_flowers.jpg'
            expect(client.replace_file(existing_img,replacement_img).code).to eq '200'
        end
        it 'updates a file' do
            query.clear
            query.add_option('original_filename','rspec_flowers.jpg')
            query.add_option('textMatching','exact')
            file = client.get_files(query).first
            file.caption = 'RSpecTest'
            expect(client.update_files(file).code).to eq '200'
        end
        it 'deletes a file' do
            query.clear
            query.add_option('original_filename','rspec_flowers.jpg')
            query.add_option('textMatching','exact')
            file = client.get_files(query).first
            expect(client.delete_files(file).code).to eq '204'
        end
    end

    ##########
    # Groups #
    ##########
    context 'when dealing with groups' do
        it 'creates a group' do
            group = Groups.new('RSpecTest')
            object = client.create_groups(group,true).first
            expect(objet.is_a?(Groups)).to be true
        end
        it 'retrieves a group' do
            object = client.get_groups.first
            expect(object.is_a?(Groups)).to be true
        end
        it 'updates a group' do
            query.clear
            query.add_option('name','RSpecTest')
            query.add_option('textMatching','exact')
            group = client.get_groups(query).first
            group.name = 'RSpecTest-Updated'
            expect(client.update_groups(group).code).to eq '200'
        end
        it 'deletes a group' do
            query.clear
            query.add_option('name','RSpecTest-Updated')
            query.add_option('textMatching','exact')
            group = client.get_groups(query)
            expect(client.delete_groups(group).code).to eq '204'
        end
    end

    ######################
    # Keyword Categories #
    ######################
    context 'when dealing with keyword categories' do
        it 'creates a keyword category' do
            system_category_id = 2 # Reference
            keyword_category = KeywordCategories.new('RSpecTest',system_category_id)
            object  = create_keyword_categories(keyword_category,true).first
            expect(object.is_a?(KeywordCategories)).to be true
        end
        it 'retrieves a keyword category' do
            object = client.get_keyword_categories.first
            expect(object.is_a?(KeywordCategories)).to be true
        end
        it 'updates a keyword category' do
            query.clear
            query.add_option('name','RSpecTest')
            query.add_option('textMatching','exact')
            keyword_category = client.get_keyword_categories(query).first
            keyword_category.name = 'RSpecTest-Updated'
            expect(client.update_keyword_categories(keyword_category).code).to eq '200'
        end
        it 'deletes a keyword category' do
            query.clear
            query.add_option('name','RSpecTest-Updated')
            query.add_option('textMatching','exact')
            keyword_category = client.get_keyword_categories(query).first
            expect(client.delete_keyword_categories(keyword_category).code).to eq '204'
        end
    end

    ############
    # Keywords #
    ############
    context 'when dealing with keywords' do
        it 'creates a keyword' do
            keyword_category_id = 5 # Type of Asset in Referece category
            keyword = Keywords.new(keyword_category_id,'RSpecTest')
            object = client.create_keywords(keyword,true).first
            expect(object.is_a?(Keywords)).to be true
        end
        it 'retrieves a keyword' do
            object = client.get_keywords.first
            expect(object.is_a?(Keywords)).to be true
        end
        it 'updates a keyword' do
            query.clear
            query.add_option('name','RSpecTest')
            query.add_option('keyword_category_id','5')
            query.add_option('textMatching','exact')
            keyword = client.get_keywords(query).first
            keyword.name = 'RSpecTest-Updated'
            expect(client.update_keywords(keyword).code).to eq '200'
        end
        it 'deletes a keyword' do
            query.clear
            query.add_option('name','RSpecTest-Updated')
            query.add_option('keyword_category_id','5')
            query.add_option('textMatching','exact')
            keyword = client.get_keywords(query).first
            expect(client.delete_keywords(keyword).code).to eq '204'
        end
    end


    context 'object with nested fields' do

    end

    context 'user with nested groups' do

    end

    context 'group with nested users' do

    end


    context 'project object with nested keywords' do

    end



    #################
    # Photographers #
    #################
    context 'when dealing with photographers' do
        suffix = DateTime.now.strftime("%Y%m%d%H%M%S")
        it 'creates a photographer' do
            photographer = Photographers.new("RSpecTest_#{suffix}")
            object = client.create_photographers(photographer,true).first
            expect(object.is_a?(Photographers)).to be true
        end
        it 'retrieves a photographer' do
            object = client.get_photographers.first
            expect(object.is_a?(Photographers)).to be true
        end
        it 'updates a photographer' do
            query.clear
            query.add_option('name',"RSpecTest_#{suffix}")
            query.add_option('textMatching','exact')
            photographer = client.get_photographers(query).first
            photographer.name = "RSpecTest_Updated_#{suffix}"
            expect(client.update_photographers(photographer).code).to eq '200'
        end
    end

    ##############################
    # Project Keyword Categories #
    ##############################
    context 'when dealing with project keyword categories' do
        it 'creates a project keyword category' do
            project_keyword_category = ProjectKeywordCategories.new('RSpecTest')
            object = client.create_project_keyword_categories(project_keyword_category,true).first
            expect(object.is_a?(ProjectKeywordCategories)).to be true
        end
        it 'retrieves a project keyword category' do
            object = client.get_project_keyword_categories.first
            expect(object.is_a?(ProjectKeywordCategories)).to be true
        end
        it 'updates a project keyword category' do
            query.clear
            query.add_option('name','RSpecTest')
            query.add_option('textMatching','exact')
            project_keyword_category = client.get_project_keyword_categories(query).first
            project_keyword_category.name = 'RSpecTest-Updated'
            expect(client.update_project_keyword_categories(project_keyword_category).code).to eq '200'
        end
        it 'deletes a project keyword category' do
            query.clear
            query.add_option('name','RSpecTest-Updated')
            query.add_option('textMatching','exact')
            project_keyword_category = client.get_project_keyword_categories(query).first
            expect(client.delete_project_keyword_category(project_keyword_category).code).to eq '204'
        end
    end

    ####################
    # Project Keywords #
    ####################
    context 'when dealing with project keywords' do
        it 'creates a project keyword' do
            project_keyword = ProjectKeywords.new('RSpecTest')
            object = client.create_project_keywords(project_keyword,true).first
            expect(object.is_a?(ProjectKeywords)).to be true
        end
        it 'retrieves a project keyword' do
            object = client.get_project_keywords.first
            expect(object.is_a?(ProjectKeywords)).to be true
        end
        it 'updates a project keyword' do
            query.clear
            query.add_option('name','RSpecTest')
            query.add_option('textMatching','exact')
            project_keyword = client.get_project_keywords(query).first
            project_keyword.name = 'RSpecTest-Updated'
            expect(client.update_project_keywords(project_keyword).code).to eq '200'
        end
    end

    ############
    # Projects #
    ############
    context 'when dealing with projects' do
        context 'with location' do
            it 'creates a project' do
                project = Projects.new('RSpecTest')
                project.set_location('40.7128 N , 74.0060 W')
                object = client.create_projects(project,true).first
                expect(object.is_a?(Projects)).to be true
            end
            it 'retrieves a project' do
                object = client.get_project_keywords.first
                expect(object.is_a?(Projects)).to be true
            end
            it 'updates a project' do
                query.clear
                query.add_option('name','RSpecTest')
                query.add_option('textMatching','exact')
                project = client.get_projects(query).first
                project.name = 'RSpecTest-Updated'
                expect(client.update_projects(project).code).to eq '200'
            end
            it 'deletes a project' do
                query.clear
                query.add_option('name','RSpecTest-Updated')
                query.add_option('textMatching','exact')
                project = client.get_projects(query).first
                expect(client.delete_projects(project).code).to eq '204'
            end
        end
    end

    ############
    # Searches #
    ############
    context 'when dealing with searches' do
        it 'creates a search' do
            args = {
                'code'       => 'rank',
                'exclude'    => '0',
                'operator'   => '<',
                'values/ids' => ['6']
            }
            search_item = SearchItems.new(args)
            search = Searches.new('search1',search_items_object)
        end
        it 'retrieves a search' do
            expect(client.get_searches.first.class.to_s).to eq 'Searches'
        end
        it 'updates a search' do

        end
    end

    context 'search object with nested search' do

    end

    #########
    # Sizes #
    #########
    context 'when dealing with sizes' do
        it 'retrieves a search' do
            expect(client.get_sizes.first.class.to_s).to eq 'Sizes'
        end
    end

    #################
    # Text Rewrites #
    #################
    context 'when dealing with text rewrites' do
        it 'retrieves a text rewrite' do
            expect(client.get_text_rewrites.first.class.to_s).to eq 'TextRewrites'
        end
    end

    #########
    # Users #
    #########
    context 'when dealing with users' do
        it 'retrieves a user' do
            expect(client.get_users.first.class.to_s).to eq 'users'
        end
    end

end