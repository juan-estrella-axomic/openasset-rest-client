require_relative '../lib/openasset-rest-client'
require_relative 'spec_helper'

include OpenAsset

RSpec.describe RestClient do

    before(:all) do
        instance = 'demo-jes.openasset.com'
        username = 'respec_user'
        @client = RestClient.new(instance,username)
        @query  = RestOptions.new
        @suffix = Helpers.current_time_in_milliseconds()
    end

    # #let(:@query) { RestOptions.new }

    # #################
    # # Access Levels #
    # #################
    # context 'when dealing with access levels' do
    #     describe '#get_access_level' do
    #         it 'retrieves an access level' do
    #             object = @client.get_access_levels.first
    #             expect(object.is_a?(AccessLevels)).to be true
    #         end
    #     end
    # end

    # ##########
    # # Albums #
    # ##########
    # context 'when dealing with albums' do
    #     name   = Helpers.generate_unique_name()
    #     describe '#get_albums' do
    #         it 'retrieves an album' do
    #             object = @client.get_albums.first
    #             expect(object.is_a?(Albums)).to be true
    #         end
    #     end
    #     describe '#create_albums' do
    #         it 'creates an album' do
    #             album = Albums.new(name)
    #             object = @client.create_albums(album,true).first
    #             expect(object.is_a?(Albums)).to be true
    #         end
    #     end
    #     describe '#update_albums' do
    #         it 'modifies an album' do
    #             @query.clear
    #             @query.add_option('name',name)
    #             @query.add_option('textMatching','exact')
    #             album = @client.get_albums(@query).first
    #             name = "RspecTest-Updated_#{@suffix}" #Update the name for delete query
    #             album.name = name
    #             expect(@client.update_albums(album).code).to eq '200'
    #         end
    #     end
    #     describe '#delete_albums' do
    #         it 'deletes an album' do
    #             @query.clear
    #             @query.add_option('name',name)
    #             @query.add_option('textMatching','exact')
    #             album = @client.get_albums(@query)
    #             expect(@client.delete_albums(album).empty?).to be true #Delete return empty array
    #         end
    #     end
    # end

    # ####################
    # # Alternate Stores #
    # ####################
    # context 'when dealing with alternate stores' do
    #     describe '#get_alternate_stores' do
    #         it 'retrieves an alternate store' do
    #             object = @client.get_alternate_stores.first
    #             expect(object.is_a?(AlternateStores)).to be true
    #         end
    #     end
    # end

    # ################
    # # Apect Ratios #
    # ################
    # context 'when dealing with aspect ratios' do
    #     describe '#get_aspect_ratios' do
    #         it 'retrieves an aspect ratio' do
    #             object = @client.get_aspect_ratios.first
    #             expect(object.is_a?(AspectRatios)).to be true
    #         end
    #     end
    # end

    # ##############
    # # Categories #
    # ##############
    # context 'when dealing with categories' do
    #     describe '#get_categories' do
    #         it 'retrieves a category' do
    #             object = @client.get_categories.first
    #             expect(object.is_a?(Categories)).to be true
    #         end
    #     end
    #     describe '#update_categories' do
    #         it 'modifies an category' do
    #             @query.clear
    #             @query.add_option('name','Reference')
    #             @query.add_option('textMatching','exact')
    #             category = @client.get_categories(@query).first
    #             category.name = 'Reference-Updated'
    #             @client.update_categories(category)
    #             @query.clear
    #             @query.add_option('name','Reference-Updated')
    #             @query.add_option('textMatching','exact')
    #             category = @client.get_categories(@query).first
    #             category.name = 'Reference'
    #             expect(@client.update_categories(category).code).to eq '200'
    #         end
    #     end
    # end

    # #####################
    # # Copyright Holders #
    # #####################
    # context 'when dealing with copyright holders' do
    #     name = Helpers.generate_unique_name()
    #     describe '#create_copyright_holders' do
    #         it 'creates a copyright holder' do
    #             copyright_holder = CopyrightHolders.new(name)
    #             object = @client.create_copyright_holders(copyright_holder,true).first
    #             expect(object.is_a?(CopyrightHolders)).to be true
    #         end
    #     end
    #     describe '#get_copyright_holders' do
    #         it 'retrieves a copyright holder' do
    #             object = @client.get_copyright_holders.first
    #             expect(object.is_a?(CopyrightHolders)).to be true
    #         end
    #     end
    # end

    # #####################
    # # Copyright Polices #
    # #####################
    # context 'when dealing with copyright policies' do
    #     name = Helpers.generate_unique_name()
    #     describe '#create_copyright_policies' do
    #         it 'creates a copyright policy' do
    #             copyright_policy = CopyrightPolicies.new(name)
    #             object = @client.create_copyright_policies(copyright_policy,true).first
    #             expect(object.is_a?(CopyrightPolicies)).to be true
    #         end
    #     end
    #     describe '#get_copyright_policies' do
    #         it 'retrieves a copyright policy' do
    #             object = @client.get_copyright_policies.first
    #             expect(object.is_a?(CopyrightPolicies)).to be true
    #         end
    #     end
    #     describe '#update_copyright_policies' do
    #         it 'modifies a copyright policy' do
    #             @query.clear
    #             @query.add_option('name',name)
    #             @query.add_option('textMatching','exact')
    #             copyright_policy = @client.get_copyright_policies(@query).first
    #             copyright_policy.name = "#{name}_Updated"
    #             expect(@client.update_copyright_policies(copyright_policy).code).to eq '200'
    #         end
    #     end
    #     describe '#delete_copyright_policies' do
    #         it 'deletes a copyright policy' do
    #             @query.clear
    #             @query.add_option('name',"#{name}_Updated")
    #             @query.add_option('textMatching','exact')
    #             copyright_policy = @client.get_copyright_policies(@query)
    #             # Copyright Policies can only be merged - NOT DELETED
    #             expect(@client.
    #                 delete_copyright_policies(copyright_policy)
    #                 .first['http_status_code']).to eq '403'
    #         end
    #     end
    # end

    # #####################
    # # Data Integrations #
    # #####################
    # context 'when dealing with data integrations' do
    #     describe '#get_data_integrations' do
    #         it 'retrieves a data integration' do
    #             object = @client.get_data_integrations.first
    #             expect(object.nil?).to be true
    #         end
    #     end
    # end

    # ##########
    # # Fields #
    # ##########
    # context 'when dealing with fields' do
    #     name = Helpers.generate_unique_name()
    #     describe '#create_fields' do
    #         it 'creates a field' do
    #             field = Fields.new(name,'image','singleLine')
    #             object = @client.create_fields(field,true).first
    #             expect(object.is_a?(Fields)).to be true
    #         end
    #     end
    #     describe '#get_fields' do
    #         it 'retrieves a field' do
    #             object = @client.get_fields.first
    #             expect(object.is_a?(Fields)).to be true
    #         end
    #     end
    #     describe '#update_fields' do
    #         it 'modifies a field' do
    #             @query.clear
    #             @query.add_option('name',name)
    #             @query.add_option('textMatching','exact')
    #             field = @client.get_fields(@query).first
    #             field.name = "#{name}-Updated"
    #             expect(@client.update_fields(field).code).to eq '200'
    #         end
    #     end
    #     describe '#delete_fields' do
    #         it 'deletes a field' do
    #             @query.clear
    #             @query.add_option('name',"#{name}-Updated")
    #             @query.add_option('textMatching','exact')
    #             field = @client.get_fields(@query)
    #             expect(@client.delete_fields(field).empty?).to be true
    #         end
    #     end
    # end

    # ########################
    # # Field Lookup Strings #
    # ########################
    # context 'when dealing with field lookup strings' do
    #     name = Helpers.generate_unique_name()
    #     field = {'id' => '31'}
    #     describe '#create_field_lookup_strings' do
    #         it 'creates a field lookup string' do
    #             field_lookup_string = FieldLookupStrings.new(name)
    #             object = @client.create_field_lookup_strings(field,field_lookup_string,true).first
    #             expect(object.is_a?(FieldLookupStrings)).to be true
    #         end
    #     end
    #     describe '#get_fieldd_lookup_strings' do
    #         it 'retrieves a field lookup string' do
    #             object = @client.get_field_lookup_strings(field).first
    #             expect(object.is_a?(FieldLookupStrings)).to be true
    #         end
    #     end
    #     describe '#update_field_lookup_strings' do
    #         it 'modifies a field lookup string' do
    #             @query.clear
    #             @query.add_option('name',name)
    #             @query.add_option('textMatching','exact')
    #             field_lookup_string = @client.get_field_lookup_strings(field,@query).first
    #             field_lookup_string.value = "#{name}-Updated"
    #             expect(@client.update_field_lookup_strings(field,field_lookup_string).code).to eq '200'
    #         end
    #     end
    #     describe '#delete_field_lookup_strings' do
    #         it 'deletes a field lookup string' do
    #             @query.clear
    #             @query.add_option('name',"#{name}-Updated")
    #             @query.add_option('textMatching','exact')
    #             field_lookup_string = @client.get_field_lookup_strings(field,@query).first
    #             expect(@client.delete_field_lookup_strings(field,field_lookup_string).empty?).to be true
    #         end
    #     end
    # end

    #########
    # Files #
    #########
    # context 'when dealing with files' do
    #     describe '#upload_files' do
    #         it 'uploads a file' do
    #             file_path = './resources/rspec_bird.jpg'
    #             category  = 2 # Reference
    #             expect(@client.upload_file(file_path,category).code).to eq '201'
    #         end
    #     end
    #     context 'retrieves a file with nested resources' do
    #         describe '#get_files' do
    #             file = nil
    #             it 'is a file' do
    #                 @query.clear
    #                 @query.add_option('id','11458') #file in OA containing nested resources
    #                 file = @client.get_files(@query,true).first
    #                 expect(file.is_a?(Files)).to be true
    #             end
    #             it 'has sizes' do
    #                 expect(file.sizes.first.is_a?(NestedSizeItems)).to be true
    #             end
    #             it 'has keywords' do
    #                 expect(file.keywords.first.is_a?(NestedKeywordItems)).to be true
    #             end
    #             it 'has fields' do
    #                 expect(file.fields.first.is_a?(NestedFieldItems)).to be true
    #             end
    #         end
    #     end
    #     describe '#replace_file' do
    #         it 'replaces a file' do
    #             @query.clear
    #             @query.add_option('original_filename','rspec_bird.jpg')
    #             @query.add_option('textMatching','exact')
    #             existing_img = @client.get_files(@query).first
    #             replacement_img = './resources/rspec_flowers.jpg'
    #             expect(@client.replace_file(existing_img,replacement_img).code).to eq '200'
    #         end
    #     end
    #     describe '#update_files' do
    #         it 'modifies a file' do
    #             @query.clear
    #             @query.add_option('original_filename','rspec_flowers.jpg')
    #             @query.add_option('textMatching','exact')
    #             file = @client.get_files(@query).first
    #             file.caption = 'RSpecTest'
    #             expect(@client.update_files(file).code).to eq '200'
    #         end
    #     end
    #     describe '#delete_files' do
    #         it 'deletes a file' do
    #             @query.clear
    #             @query.add_option('original_filename','rspec_flowers.jpg')
    #             @query.add_option('textMatching','exact')
    #             file = @client.get_files(@query).first
    #             expect(@client.delete_files(file).empty?).to be true
    #         end
    #     end
    # end

    # ##########
    # # Groups #
    # ##########
    # context 'when dealing with groups with nested resources' do
    #     before(:all) do # Prep: create nested user
    #         user = Users.new('rspec@axomic.com','RSpec Test','pass')
    #         @user = @client.create_users(user,true).first
    #         @nested_user = NestedUserItems.new(@user.id)
    #     end
    #     describe '#create_groups' do
    #         it 'creates a group' do
    #             g = Groups.new('RSpecTest')
    #             group = @client.create_groups(g,true).first
    #             expect(group.is_a?(Groups)).to be true
    #         end
    #     end
    #     describe '#update_groups' do
    #         it 'modifies a group' do
    #             @query.clear
    #             @query.add_option('name','RSpecTest')
    #             group = @client.get_groups(@query,true).first
    #             group.name = 'RSpecTest-Updated'
    #             group.users << @nested_user
    #             expect(@client.update_groups(group).code).to eq '200'
    #         end
    #     end
    #     describe '#get_groups' do
    #         group = nil
    #         it 'retrieves a group' do
    #             @query.clear
    #             @query.add_option('name','RSpecTest-Updated')
    #             @query.add_option('textMatching','exact')
    #             @query.add_option('users','all')
    #             group = @client.get_groups(@query).first
    #             expect(group.is_a?(Groups)).to be true
    #         end
    #         it 'has the created user' do
    #             expect(group.users.first.id).to eq @user.id
    #         end
    #     end

    #     describe '#delete_groups' do
    #         it 'deletes a group' do
    #             @query.clear
    #             @query.add_option('name','RSpecTest-Updated')
    #             @query.add_option('textMatching','exact')
    #             group = @client.get_groups(@query).first
    #             expect(@client.delete_groups(group).empty?).to be true
    #         end
    #     end
    #     after(:all) do # Clean up: delete created user
    #         @client.delete_users(@user)
    #     end
    # end

    # ######################
    # # Keyword Categories #
    # ######################
    # context 'when dealing with keyword categories' do
    #     describe '#create_keyword_categories' do
    #         it 'creates a keyword category' do
    #             system_category_id = 2 # Reference
    #             keyword_category = KeywordCategories.new('RSpecTest',system_category_id)
    #             object  = create_keyword_categories(keyword_category,true).first
    #             expect(object.is_a?(KeywordCategories)).to be true
    #         end
    #     end
    #     describe '#get_keyword_categories' do
    #         it 'retrieves a keyword category' do
    #             object = @client.get_keyword_categories.first
    #             expect(object.is_a?(KeywordCategories)).to be true
    #         end
    #     end
    #     describe '#update_keyword_categories' do
    #         it 'modifies a keyword category' do
    #             @query.clear
    #             @query.add_option('name','RSpecTest')
    #             @query.add_option('textMatching','exact')
    #             keyword_category = @client.get_keyword_categories(@query).first
    #             keyword_category.name = 'RSpecTest-Updated'
    #             expect(@client.update_keyword_categories(keyword_category).code).to eq '200'
    #         end
    #     end
    #     describe '#delete_keyword_categories' do
    #         it 'deletes a keyword category' do
    #             @query.clear
    #             @query.add_option('name','RSpecTest-Updated')
    #             @query.add_option('textMatching','exact')
    #             keyword_category = @client.get_keyword_categories(@query).first
    #             expect(@client.delete_keyword_categories(keyword_category).code).to eq '204'
    #         end
    #     end
    # end

    # ############
    # # Keywords #
    # ############
    # context 'when dealing with keywords' do
    #     describe '#create_keywords' do
    #         it 'creates a keyword' do
    #             keyword_category_id = 5 # Type of Asset in Referece category
    #             keyword = Keywords.new(keyword_category_id,'RSpecTest')
    #             object = @client.create_keywords(keyword,true).first
    #             expect(object.is_a?(Keywords)).to be true
    #         end
    #     end
    #     describe '#get_keyords' do
    #         it 'retrieves a keyword' do
    #             object = @client.get_keywords.first
    #             expect(object.is_a?(Keywords)).to be true
    #         end
    #     end
    #     describe '#update_keywords' do
    #         it 'modifies a keyword' do
    #             @query.clear
    #             @query.add_option('name','RSpecTest')
    #             @query.add_option('keyword_category_id','5')
    #             @query.add_option('textMatching','exact')
    #             keyword = @client.get_keywords(@query).first
    #             keyword.name = 'RSpecTest-Updated'
    #             expect(@client.update_keywords(keyword).code).to eq '200'
    #         end
    #     end
    #     describe '#delete_keywords' do
    #         it 'deletes a keyword' do
    #             @query.clear
    #             @query.add_option('name','RSpecTest-Updated')
    #             @query.add_option('keyword_category_id','5')
    #             @query.add_option('textMatching','exact')
    #             keyword = @client.get_keywords(@query).first
    #             expect(@client.delete_keywords(keyword).code).to eq '204'
    #         end
    #     end
    # end

    # #################
    # # Photographers #
    # #################
    # context 'when dealing with photographers' do
    #     name= Helpers.generate_unique_name()
    #     describe '#create_photographers' do
    #         it 'creates a photographer' do
    #             photographer = Photographers.new(name)
    #             object = @client.create_photographers(photographer,true).first
    #             expect(object.is_a?(Photographers)).to be true
    #         end
    #     end
    #     describe '#get_photographers' do
    #         it 'retrieves a photographer' do
    #             object = @client.get_photographers.first
    #             expect(object.is_a?(Photographers)).to be true
    #         end
    #     end
    #     describe '#update_photographers' do
    #         it 'modifies a photographer' do
    #             @query.clear
    #             @query.add_option('name',name)
    #             @query.add_option('textMatching','exact')
    #             photographer = @client.get_photographers(@query).first
    #             photographer.name = "#{name}_Updated"
    #             expect(@client.update_photographers(photographer).code).to eq '200'
    #         end
    #     end
    # end

    # ##############################
    # # Project Keyword Categories #
    # ##############################
    # context 'when dealing with project keyword categories' do
    #     describe '#create_project_keyword_categories' do
    #         it 'creates a project keyword category' do
    #             project_keyword_category = ProjectKeywordCategories.new('RSpecTest')
    #             object = @client.create_project_keyword_categories(project_keyword_category,true).first
    #             expect(object.is_a?(ProjectKeywordCategories)).to be true
    #         end
    #     end
    #     describe '#get_project_keyword_categories' do
    #         it 'retrieves a project keyword category' do
    #             object = @client.get_project_keyword_categories.first
    #             expect(object.is_a?(ProjectKeywordCategories)).to be true
    #         end
    #     end
    #     describe '#update_project_keyword_categories' do
    #         it 'modifies a project keyword category' do
    #             @query.clear
    #             @query.add_option('name','RSpecTest')
    #             @query.add_option('textMatching','exact')
    #             project_keyword_category = @client.get_project_keyword_categories(@query).first
    #             project_keyword_category.name = 'RSpecTest-Updated'
    #             expect(@client.update_project_keyword_categories(project_keyword_category).code).to eq '200'
    #         end
    #     end
    #     describe '#delete_project_keyword_categories' do
    #         it 'deletes a project keyword category' do
    #             @query.clear
    #             @query.add_option('name','RSpecTest-Updated')
    #             @query.add_option('textMatching','exact')
    #             project_keyword_category = @client.get_project_keyword_categories(@query).first
    #             expect(@client.delete_project_keyword_category(project_keyword_category).empty?).to be true
    #         end
    #     end
    # end

    # ####################
    # # Project Keywords #
    # ####################
    # context 'when dealing with project keywords' do
    #     describe '#create_project_keywords' do
    #         it 'creates a project keyword' do
    #             project_keyword = ProjectKeywords.new('RSpecTest','13')
    #             object = @client.create_project_keywords(project_keyword,true).first
    #             expect(object.is_a?(ProjectKeywords)).to be true
    #         end
    #     end
    #     describe '#get_project_keywords' do
    #         it 'retrieves a project keyword' do
    #             object = @client.get_project_keywords.first
    #             expect(object.is_a?(ProjectKeywords)).to be true
    #         end
    #     end
    #     describe '#update_project_keywords' do
    #         it 'modifies a project keyword' do
    #             @query.clear
    #             @query.add_option('name','RSpecTest')
    #             @query.add_option('textMatching','exact')
    #             project_keyword = @client.get_project_keywords(@query).first
    #             project_keyword.name = 'RSpecTest-Updated'
    #             expect(@client.update_project_keywords(project_keyword).code).to eq '200'
    #         end
    #     end
    #     describe '#delete_project_keywords' do
    #         it 'deletes a project keyword' do
    #             @query.clear
    #             @query.add_option('name','RSpecTest-Updated')
    #             @query.add_option('project_keyword_category_id','13')
    #             @query.add_option('textMatching','exact')
    #             project_keyword = @client.get_project_keywords(@query).first
    #             expect(@client.delete_project_keywords(project_keyword).empty?).to be true
    #         end
    #     end
    # end

    ############
    # Projects #
    ############
    # context 'when dealing with projects' do
    #     context 'with location' do
    #         before(:all) do
    #             @project = Projects.new('RSpecTest','1000.123')
    #         end
    #         describe '#create_projects' do
    #             it 'creates a project' do
    #                 @project.set_location('40.7128 N , 74.0060 W')
    #                 @project = @client.create_projects(@project,true).first
    #                 expect(@project.is_a?(Projects)).to be true
    #             end
    #         end
    #         describe '#get_projects' do
    #             it 'retrieves a project' do
    #                 object = @client.get_projects.first
    #                 expect(object.is_a?(Projects)).to be true
    #             end
    #         end
    #         describe '#update_projects' do
    #             it 'modifies a project' do
    #                 @query.clear
    #                 @query.add_option('name','RSpecTest')
    #                 project = @client.get_projects(@query).first
    #                 project.name = 'RSpecTest-Updated'
    #                 expect(@client.update_projects(project).code).to eq '200'
    #             end
    #         end
    #         describe '#delete_projects' do
    #             it 'deletes a project' do
    #                 @query.clear
    #                 @query.add_option('name','RSpecTest-Updated')
    #                 @query.add_option('textMatching','exact')
    #                 project = @client.get_projects(@query).first
    #                 expect(@client.delete_projects(project).empty?).to eq true
    #             end
    #         end
    #     end

    #     context 'with nested resources' do
    #         project = nil
    #         before(:all) do
    #             album_name = Helpers.generate_unique_name()
    #             @album   = Albums.new(album_name)
    #             @album   = @client.create_albums(@album,true).first

    #             project_keyword_name = Helpers.generate_unique_name()
    #             project_keyword_category_id = '13'
    #             @project_keyword = ProjectKeywords.new(project_keyword_name,
    #                                                    project_keyword_category_id)
    #             @project_keyword = @client.create_project_keywords(@project_keyword,true).first

    #             field_name = Helpers.generate_unique_name()
    #             @field = Fields.new(field_name,'project','singleLine')
    #             @field = @client.create_fields(@field,true).first
    #         end
    #         describe '#create_projects' do
    #             it 'creates a project' do
    #                 project = Projects.new('RSpecTest','1234.56')
    #                 project = @client.create_projects(project,true).first
    #                 expect(project.is_a?(Projects)).to be true
    #             end
    #         end
    #         describe '#updates_projects' do
    #             it 'updates a project' do
    #                 project.project_keywords << NestedProjectKeywordItems.new(@project_keyword.id)
    #                 project.fields << NestedFieldItems.new(@field.id,['RSpect Test Sample Data'])
    #                 project.albums << NestedAlbumItems.new(@album.id)
    #                 expect(@client.update_projects(project).code).to eq '200'
    #             end
    #         end
    #         describe '#get_projects' do
    #             it 'retrieves a project' do
    #                 @query.clear
    #                 @query.add_option('name','RSpecTest')
    #                 @query.add_option('textMatching','exact')
    #                 @query.add_option('albums','all')
    #                 @query.add_option('projectKeywords','all')
    #                 @query.add_option('fields','all')
    #                 @project = @client.get_projects(@query).first
    #             end
    #             it 'has a field' do
    #                 expect(project.fields.first.id).to eq @field.id
    #             end
    #             it 'has a project keyword' do
    #                 expect(project.project_keywords.first.id).to eq @project_keyword.id
    #             end
    #             it 'has an album' do
    #                 expect(project.albums.first.id).to eq @album.id
    #             end
    #         end
    #         after(:all) do
    #             @client.delete_projects(project)
    #         end
    #     end
    # end

    # ############
    # # Searches #
    # ############
    # context 'when dealing with searches' do
    #     describe '#create_searches' do
    #         it 'creates a search' do
    #             args = {
    #                 'code'       => 'rank',
    #                 'exclude'    => '0',
    #                 'operator'   => '<',
    #                 'values/ids' => ['6']
    #             }
    #             suffix = Helpers.current_time_in_milliseconds()
    #             search_item = SearchItems.new(args)
    #             search = Searches.new("RSpecTestSearch_#{@suffix}",search_items)
    #             object = @client.create_searches(search,true).first
    #             expect(object.is_a?(Searhes)).to be true
    #         end
    #     end
    #     describe '#get_searches' do
    #         it 'retrieves a search' do
    #             object = @client.get_searches.first
    #             expect(object.is_a?(Searches)).to be true
    #         end
    #     end
    #     describe '#update_searches' do
    #         it 'modifies a search' do
    #             @query.clear
    #             @query.add_option('name',"RSpecTestSearch_#{suffix}")
    #             @query.add_option('textMatching','exact')
    #             search = @client.get_searches(@query).first
    #             search.name = "RSpecTestSearch-Updated_#{suffix}"
    #             expect(@client.update_searchess(searche).code).to eq '200'
    #         end
    #     end
    # end

    # #########
    # # Sizes #
    # #########
    # context 'when dealing with sizes' do
    #     describe '#create_image_sizes' do
    #         it 'creates an image size' do
    #             img_size = Sizes.new('RSpecTest')
    #             object = @client.create_image_sizes(img_size,true).first
    #             expect(object.is_a?(Sizes)).to be true
    #         end
    #     end
    #     describe '#get_image_sizes' do
    #         it 'retrieves an image size' do
    #             object = @client.get_image_sizes.first
    #             expect(object.is_a?(Sizes)).to be true
    #         end
    #     end
    #     describe '#update_image_sizes' do
    #         it 'modifies an image size' do
    #             @query.clear
    #             @query.add_option('name','RSpecTest')
    #             @query.add_option('textMatching','exact')
    #             img_size = @client.get_image_sizes(@query).first
    #             img_size.name = 'RSpecTest-Updated'
    #             expect(@client.update_image_sizes(img_size).code).to eq '200'
    #         end
    #     end
    #     describe '#delete_image_sizes' do
    #         it 'deletes an image size' do
    #             @query.clear
    #             @query.add_option('name','RSpecTest-Updated')
    #             @query.add_option('textMatching','exact')
    #             img_size = @client.get_image_sizes(@query).first
    #             expect(@client.delete_image_sizes(img_size).code).to eq '200'
    #         end
    #     end
    # end

    # #################
    # # Text Rewrites #
    # #################
    # context 'when dealing with text rewrites' do
    #     describe '#get_text_rewrites' do
    #         it 'retrieves a text rewrite' do
    #             object = @client.get_text_rewrites.first
    #             test = false
    #             test = true if object.nil? || object.is_a?(TextRewrites)
    #             expect(test).to be true
    #         end
    #     end
    # end

    # #########
    # # Users #
    # #########
    # context 'when dealing with users' do
    #     context 'with nested groups' do
    #         before(:all) do
    #             @suffix = Helpers.current_time_in_milliseconds()
    #             @name   = "RSpecTest_#{@suffix}"
    #             @group  = Groups.new(name)
    #             @group  = @client.create_groups(@group,true).first
    #             data = {
    #                 :username  => 'jdoe@axomic.com',
    #                 :full_name => 'John Doe',
    #                 :password  => 'pass'
    #             }
    #             @user = Users.new(data)
    #         end
    #         describe '#create_users' do
    #             it 'creates a user' do
    #                 @user = @client.create_users(@user,true).first
    #                 expect(@user.is_a?(Users)).to be true
    #             end
    #         end
    #         describe '#update_users' do
    #             it 'modifies a user' do
    #                 @user.full_name = 'Jane Doe'
    #                 @user.groups << NestedGroupItems.new(@group.id)
    #                 expect(@client.update_users(@user).code).to eq '200'
    #             end
    #         end
    #         describe '#get_users' do
    #             it 'retrieves a user' do
    #                 @query.clear
    #                 @query.add_option('id',@user.id)
    #                 @query.add_option('groups','all')
    #                 @user = @client.get_users(@query).first
    #                 expect(@user.is_a?(Users)).to be true
    #             end
    #             it 'is assigned to a group' do
    #                 expect(@user.groups.first.id).to eq @group.id
    #             end
    #         end
    #         describe '#delete_users' do
    #             it 'deletes a user' do
    #                 expect(@client.delete_users(@user).code).to eq '204'
    #             end
    #         end
    #         after(:all) do
    #             @client.delete_groups(@group)
    #         end
    #     end
    # end
end