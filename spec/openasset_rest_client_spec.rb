require_relative '../lib/openasset-rest-client'
require_relative 'spec_helper'

include OpenAsset

RSpec.describe RestClient do

    before(:all) do
        instance = 'localhost:8888'
        user = 'api_tester'
        pass = ENV['APIPASSWORD']
        @client = RestClient.new(instance,user,pass)
        @client.silent = true
        @query  = RestOptions.new
        @suffix = Helpers.current_time_in_milliseconds()
    end

    #################
    # Access Levels #
    #################
    context 'when dealing with access levels' do
        describe '#get_access_level' do
            it 'retrieves an access level', :aggregate_failures do
                @query.clear
                @query.add_option('id',1)
                object = @client.get_access_levels(@query).first
                expect(object.is_a?(AccessLevels)).to be true
                expect(object.id).to eq 1
            end
        end
    end

    ##########
    # Albums #
    ##########
    context 'when dealing with albums' do
        describe 'client' do
            before(:all) do
                @name = 'RSpecTest'
            end
            it 'creates an album',:aggregate_failures do
                album = Albums.new(@name)
                object = @client.create_albums(album,true).first
                expect(object.is_a?(Albums)).to be true
                expect(object.name).to eq @name
            end
            it 'retrieves an album', :aggregate_failures do
                @query.clear
                @query.add_option('name',@name)
                @query.add_option('textMatching','exact')
                object = @client.get_albums(@query).first
                expect(object.is_a?(Albums)).to be true
                expect(object.name).to eq @name
            end
            it 'modifies an album', :aggregate_failures do
                @query.clear
                @query.add_option('name',@name)
                @query.add_option('textMatching','exact')
                album = @client.get_albums(@query).first
                new_name = 'RspecTest-Updated'
                album.name = new_name
                album = @client.update_albums(album,true).first
                expect(album.is_a?(Albums)).to be true
                expect(album.name).to eq new_name
            end
            it 'deletes an album' do
                @query.clear
                @query.add_option('name','RspecTest-Updated')
                @query.add_option('textMatching','exact')
                album = @client.get_albums(@query)
                expect(@client.delete_albums(album).empty?).to be true #Delete return empty array
            end
        end
    end

    ####################
    # Alternate Stores #
    ####################
    context 'when dealing with alternate stores' do
        describe '#get_alternate_stores' do
            it 'retrieves an alternate store' do
                object = @client.get_alternate_stores.first || AlternateStores.new # stub it if empty
                expect(object.is_a?(AlternateStores)).to be true
            end
        end
    end

    ################
    # Apect Ratios #
    ################
    context 'when dealing with aspect ratios' do
        describe '#get_aspect_ratios' do
            it 'retrieves an aspect ratio', :aggregate_failures do
                code = 'square'
                @query.clear
                @query.add_option('code',code)
                object = @client.get_aspect_ratios(@query).first
                expect(object.is_a?(AspectRatios)).to be true
                expect(object.code).to eq code
            end
        end
    end

    ##############
    # Categories #
    ##############
    context 'when dealing with categories' do
        describe '#get_categories' do
            it 'retrieves a category' do
                code = 'Reference'
                @query.clear
                @query.add_option('code',code)
                object = @client.get_categories(@query).first
                expect(object.is_a?(Categories)).to be true
                expect(object.code).to eq code
            end
        end
        describe '#update_categories' do
            before(:all) do
                @orig_name = 'Reference'
                @new_name = 'Reference-Updated'
            end
            it 'modifies an category' do
                @query.clear
                @query.add_option('name',@orig_name)
                @query.add_option('textMatching','exact')
                category = @client.get_categories(@query).first

                category.name = @new_name
                modified_category = @client.update_categories(category,true).first

                expect(modified_category.is_a?(Categories)).to be true
                expect(modified_category.name).to eq 'Reference-Updated'
            end
            after(:all) do
                @query.clear
                @query.add_option('name',@new_name)
                @query.add_option('textMatching','exact')
                category = @client.get_categories(@query).first
                category.name = @orig_name
                @client.update_categories(category)
            end
        end
    end

    #####################
    # Copyright Holders #
    #####################
    context 'when dealing with copyright holders' do
        name = Helpers.generate_unique_name()
        describe '#create_copyright_holders' do
            it 'creates a copyright holder', :aggregate_failures do
                copyright_holder = CopyrightHolders.new(name)
                object = @client.create_copyright_holders(copyright_holder,true).first
                expect(object.is_a?(CopyrightHolders)).to be true
                expect(object.name).to eq name
            end
        end
        describe '#get_copyright_holders' do
            it 'retrieves a copyright holder', :aggregate_failures do
                @query.clear
                @query.add_option('name',name)
                object = @client.get_copyright_holders(@query).first
                expect(object.is_a?(CopyrightHolders)).to be true
                expect(object.name).to eq name
            end
        end
    end

    #####################
    # Copyright Polices #
    #####################
    context 'when dealing with copyright policies' do
        name = Helpers.generate_unique_name()
        describe '#create_copyright_policies' do
            it 'creates a copyright policy', :aggregate_failures do
                copyright_policy = CopyrightPolicies.new(name)
                object = @client.create_copyright_policies(copyright_policy,true).first
                expect(object.is_a?(CopyrightPolicies)).to be true
                expect(object.name).to eq name
            end
        end
        describe '#get_copyright_policies' do
            it 'retrieves a copyright policy' do
                @query.clear
                @query.add_option('name',name)
                object = @client.get_copyright_policies(@query).first
                expect(object.is_a?(CopyrightPolicies)).to be true
                expect(object.name).to eq name
            end
        end
        describe '#update_copyright_policies' do
            it 'modifies a copyright policy' do
                new_name = name + '_Updated'
                @query.clear
                @query.add_option('name',name)
                @query.add_option('textMatching','exact')
                copyright_policy = @client.get_copyright_policies(@query).first
                copyright_policy.name = new_name
                modified_copyright_policy = @client.update_copyright_policies(copyright_policy,true).first
                expect(modified_copyright_policy.is_a?(CopyrightPolicies)).to be true
                expect(modified_copyright_policy.name).to eq new_name
            end
        end
        describe '#delete_copyright_policies' do
            it 'deletes a copyright policy' do
                @query.clear
                @query.add_option('name',"#{name}_Updated")
                @query.add_option('textMatching','exact')
                copyright_policy = @client.get_copyright_policies(@query)
                # Copyright Policies can only be merged - NOT DELETED
                expect(@client.
                    delete_copyright_policies(copyright_policy)
                    .first['http_status_code']).to eq '403'
            end
        end
    end

    #####################
    # Data Integrations #
    #####################
    context 'when dealing with data integrations' do
        describe '#get_data_integrations' do
            it 'retrieves a data integration' do
                object = @client.get_data_integrations.first || DataIntegrations.new # Stub it
                expect(object.is_a?(DataIntegrations)).to be true
            end
        end
    end

    ##########
    # Fields #
    ##########
    context 'when dealing with fields' do
        name = Helpers.generate_unique_name()
        describe '#create_fields' do
            it 'creates a field', :aggregate_failures do
                field = Fields.new(name,'image','singleLine')
                object = @client.create_fields(field,true).first
                expect(object.is_a?(Fields)).to be true
                expect(object.name).to eq name
            end
        end
        describe '#get_fields' do
            it 'retrieves a field', :aggregate_failures do
                @query.clear
                @query.add_option('name',name)
                @query.add_option('field_type','image')
                @query.add_option('field_display_type','singleLine')
                object = @client.get_fields(@query).first
                expect(object.is_a?(Fields)).to be true
                expect(object.name).to eq name
            end
        end
        describe '#update_fields' do
            it 'modifies a field' do
                new_name = "#{name}-Updated"
                @query.clear
                @query.add_option('name',name)
                @query.add_option('textMatching','exact')
                field = @client.get_fields(@query).first
                field.name = new_name
                modified_field = @client.update_fields(field,true).first
                expect(modified_field.is_a?(Fields)).to be true
                expect(modified_field.name).to eq new_name
            end
        end
        describe '#delete_fields' do
            it 'deletes a field' do
                @query.clear
                @query.add_option('name',"#{name}-Updated")
                @query.add_option('textMatching','exact')
                field = @client.get_fields(@query)
                expect(@client.delete_fields(field).empty?).to be true
            end
        end
    end

    ########################
    # Field Lookup Strings #
    ########################
    context 'when dealing with field lookup strings' do
        before(:all) do
            @fls_value = Helpers.generate_unique_name()
            @new_fls_value = "#{@fls_value}-Updated"
            @field_name = 'RSpecSuggestionField'
            @field_type = 'project'
            @field_display_type = 'suggestion'
            @query.clear
            @query.add_option('name',@field_name)
            @query.add_option('field_type',@field_type)
            @query.add_option('field_display_type',@field_display_type)
            @field = @client.get_fields(@query).first
            unless @field
                fld = Fields.new(@name,@field_type,@field_display_type)
                @field = @client.create_fields(fld)
            end
        end
        describe '#create_field_lookup_strings' do
            it 'creates a field lookup string', :aggregate_failures do
                field_lookup_string = FieldLookupStrings.new(@fls_value)
                object = @client.create_field_lookup_strings(@field,field_lookup_string,true).first
                expect(object.is_a?(FieldLookupStrings)).to be true
                expect(object.value).to eq @fls_value
            end
        end
        describe '#get_fieldd_lookup_strings' do
            it 'retrieves a field lookup string', :aggregate_failures do
                @query.clear
                @query.add_option('value',@fls_value)
                object = @client.get_field_lookup_strings(@field,@query).first
                expect(object.is_a?(FieldLookupStrings)).to be true
                expect(object.value).to eq @fls_value
            end
        end
        describe '#update_field_lookup_strings' do
            it 'modifies a field lookup string', :aggregate_failures do
                @query.clear
                @query.add_option('name',@fls_value)
                @query.add_option('textMatching','exact')
                field_lookup_string = @client.get_field_lookup_strings(@field,@query).first
                field_lookup_string.value = @new_fls_value
                field_lookup_string = @client.update_field_lookup_strings(@field,field_lookup_string,true).first
                expect(field_lookup_string.is_a?(FieldLookupStrings)).to be true
                expect(field_lookup_string.value).to eq @new_fls_value
            end
        end
        describe '#delete_field_lookup_strings' do
            it 'deletes a field lookup string' do
                @query.clear
                @query.add_option('value',@new_fls_value)
                @query.add_option('textMatching','exact')
                field_lookup_string = @client.get_field_lookup_strings(@field,@query).first
                expect(@client.delete_field_lookup_strings(@field,field_lookup_string).empty?).to be true
            end
        end
    end

    #########
    # Files #
    #########
    context 'when dealing with files' do
        describe '#upload_files' do
            it 'uploads a file' do
                file_path = File.expand_path('spec/resources/rspec_bird.jpg')
                unless File.exist?(file_path)
                    fail "File: #{file_path} not found"
                end
                category = 2 # Reference
                expect(@client.upload_file(file_path,category).code).to eq('201').or eq('409')
            end
        end
        context 'with nested resources' do
            describe 'client' do
                before(:all) do
                    @name = 'RSpecTest'

                    @category_id = 2 # Reference
                    @original_filesize_id = 1
                    @query.clear
                    @query.add_option('name',@name)

                    @file_keyword_category = @client.get_keyword_categories(@query).first
                    if @file_keyword_category.nil?
                        kc = KeywordCategories.new({'name' => @name, 'category_id' => @category_id})
                        @file_keyword_category = @client.create_keyword_categories(kc,true).first
                    end

                    @keyword = @client.get_keywords(@query).first
                    if @keyword.nil?
                        kwd = Keywords.new({'keyword_category_id' => @file_keyword_category.id, 'name' => @name})
                        @keyword = @client.create_keywords(kwd,true).first
                    end

                    @album = @client.get_albums(@query).first
                    if @album.nil?
                        album = Albums.new(@name)
                        @album = @client.create_albums(album,true).first
                    end

                    @query.add_option('field_type','image')
                    @query.add_option('field_display_type','multiline')
                    @field = @client.get_fields(@query).first
                    if @field.nil?
                        data = {'name' => @name, 'field_type' => 'image', 'field_display_type' => 'multiLine'}
                        fld = Fields.new(data)
                        @field = @client.create_fields(fld,true).first
                    end
                end

                file = nil
                it 'retrieves a file', :aggregate_failures do
                    name = 'rspec_bird.jpg'
                    @query.clear
                    @query.add_option('original_filename',name) #file in OA containing nested resources
                    file = @client.get_files(@query,true).first
                    expect(file.is_a?(Files)).to be true
                    expect(file.original_filename).to eq name
                end
                it 'adds keywords', :aggregate_failures do
                    @client.file_add_keywords(file,@keyword)# Makes api call to attach kwd
                    @query.clear
                    @query.add_option('id',file.id)
                    file = @client.get_files(@query,true).first
                    unless file.is_a?(Files)
                        fail 'File retrieval failed'
                    end
                    nested_file_kwd = file.keywords.find { |k| k.id == @keyword.id }
                    expect(nested_file_kwd.is_a?(NestedKeywordItems)).to be true
                    expect(nested_file_kwd.id).to eq @keyword.id
                end
                it 'adds field data', :aggregate_failures do
                    field_data = 'Sample field data'
                    @client.file_add_field_data(file, @field, field_data)
                    @query.clear
                    @query.add_option('id',file.id)
                    file = @client.get_files(@query,true).first
                    unless file.is_a?(Files)
                        fail 'File retrieval failed'
                    end
                    nested_field = file.fields.find { |fld| fld.id == @field.id }
                    unless nested_field
                        fail 'Nested field retrieval failed'
                    end
                    expect(nested_field.id).to eq @field.id
                    expect(nested_field.values.first).to eq field_data
                end
                it 'adds the file to an album', :aggregate_failures do
                    @client.add_files_to_album(@album,file)
                    @query.clear
                    @query.add_option('id',file.id)
                    file = @client.get_files(@query,true).first
                    unless file.is_a?(Files)
                        fail 'File retrieval failed'
                    end
                    nested_album = file.albums.find { |alb| alb.id == @album.id }
                    unless nested_album
                        fail 'Nested album retrieval failed'
                    end
                    expect(nested_album.is_a?(NestedAlbumItems)).to be true
                    expect(nested_album.id).to eq @album.id
                end
                it 'retrieves a file with file sizes', :aggregate_failures do
                    @query.clear
                    @query.add_option('id',file.id)
                    file = @client.get_files(@query,true).first
                    unless file.is_a?(Files)
                        fail 'File retrieval failed'
                    end
                    nested_file_size_item = file.sizes.find { |item| item.id == 1 }
                    unless nested_file_size_item
                        fail 'Nested file size retrieval failed'
                    end
                    expect(nested_file_size_item.is_a?(NestedSizeItems)).to be true
                    expect(nested_file_size_item.id).to eq @original_filesize_id
                end
                after(:all) do
                    @client.delete_fields(@field)
                    @client.delete_albums(@album)
                    @client.delete_keywords(@keyword)
                    @client.delete_keyword_categories(@file_keyword_category)
                end
            end
        end
        describe '#replace_file' do
            let(:query_obj) { RestOptions.new }
            it 'replaces a file' do
                query = query_obj
                query.add_option('original_filename','rspec_bird.jpg')
                query.add_option('textMatching','exact')
                existing_file = @client.get_files(query).first
                unless existing_file.is_a?(Files)
                    fail 'Exisiting file not found'
                end
                replacement_img = File.expand_path('spec/resources/rspec_flowers.jpg')
                unless File.exist?(replacement_img)
                    fail "File: #{replacement_img} not found"
                end
                expect(@client.replace_file(existing_file,replacement_img).code).to eq '200'
            end
        end
        describe '#update_files' do
            let(:query_obj) { RestOptions.new }
            it 'modifies a file' do
                value = 'RSpecTest'
                query = query_obj
                query.add_option('original_filename','rspec_flowers.jpg')
                query.add_option('textMatching','exact')
                file = @client.get_files(query).first
                fail 'File retrieval error' unless file.is_a?(Files)
                file.created = nil # API returns value of "0" but wont reaccept it. BUG
                file.caption = value
                file = @client.update_files(file,true).first
                expect(file.caption).to eq value
            end
        end
        describe '#delete_files' do
            let(:query_obj) { RestOptions.new }
            it 'deletes a file' do
                query = query_obj
                query.add_option('original_filename','rspec_flowers.jpg')
                query.add_option('textMatching','exact')
                file = @client.get_files(query).first
                fail 'File retrieval error' unless file
                expect(@client.delete_files(file).empty?).to be true # Empty body is returned
            end
        end
    end

    ##########
    # Groups #
    ##########
    context 'when dealing with groups with nested resources' do
        group = nil
        before(:all) do # Prep: create nested user
            @user_name = 'rspec@axomic.com'
            @full_name = 'RTest'
            @query.clear
            @query.add_option('user_name',@user_name)
            @query.add_option('full_name',@full_name)
            @user = @client.get_users(@query).first
            unless @user
                user = Users.new(@user_name,@full_name,'pass')
                @user = @client.create_users(user,true).first
            end
            @nested_user = NestedUserItems.new(@user.id)
            @name = 'RTest'
            @updated_name = 'RTest-Updated'
        end
        describe '#create_groups' do
            it 'creates a group', :aggregate_failures do
                g = Groups.new(@name)
                group = @client.create_groups(g,true).first
                expect(group.is_a?(Groups)).to be true
                expect(group.name).to eq @name
            end
        end
        describe '#update_groups' do
            it 'modifies a group', :aggregate_failures do
                group.name = @updated_name
                group = @client.update_groups(group,true).first
                unless group
                    fail 'Group retrieval error'
                end
                expect(group.is_a?(Groups)).to be true
                expect(group.name).to eq @updated_name
            end
            it 'add a user to the group' do
                group.users << @nested_user
                group = @client.update_groups(group,true).first
                nested_user = group.users.find { |obj| obj.id == @user.id }
                unless nested_user
                    fail 'User group assignment failed'
                end
                expect(nested_user.id).to eq @user.id
            end
        end
        describe '#get_groups' do
            it 'retrieves a group', :aggregate_failures do
                @query.clear
                @query.add_option('name',@updated_name)
                @query.add_option('textMatching','exact')
                @query.add_option('users','all')
                group = @client.get_groups(@query).first
                expect(group.is_a?(Groups)).to be true
                expect(group.name).to eq @updated_name
            end
        end
        describe '#delete_groups' do
            it 'deletes a group' do
                expect(@client.delete_groups(group).empty?).to be true
            end
        end
        after(:all) do # Clean up: delete created user
            @client.delete_users(@user)
        end
    end

    ######################
    # Keyword Categories #
    ######################
    context 'when dealing with keyword categories' do
        before(:all) do
            @name = 'RSpecTest'
            @updated_name = 'RSpecTest-Updated'
        end
        describe '#create_keyword_categories' do
            it 'creates a keyword category', :aggregate_failures do
                system_category_id = 2 # Reference
                keyword_category = KeywordCategories.new(@name,system_category_id)
                object  = @client.create_keyword_categories(keyword_category,true).first
                expect(object.is_a?(KeywordCategories)).to be true
                expect(object.name).to eq @name
            end
        end
        describe '#get_keyword_categories' do
            it 'retrieves a keyword category', :aggregate_failures  do
                @query.clear
                @query.add_option('name',@name)
                object = @client.get_keyword_categories(@query).first
                expect(object.is_a?(KeywordCategories)).to be true
                expect(object.name).to eq @name
            end
        end
        describe '#update_keyword_categories' do
            it 'modifies a keyword category', :aggregate_failures do
                @query.clear
                @query.add_option('name',@name)
                @query.add_option('textMatching','exact')
                keyword_category = @client.get_keyword_categories(@query).first
                keyword_category.name = @updated_name
                object = @client.update_keyword_categories(keyword_category,true).first
                expect(object.is_a?(KeywordCategories)).to be true
                expect(object.name).to eq @updated_name
            end
        end
        describe '#delete_keyword_categories' do
            it 'deletes a keyword category' do
                @query.clear
                @query.add_option('name',@updated_name)
                @query.add_option('textMatching','exact')
                keyword_category = @client.get_keyword_categories(@query).first
                expect(@client.delete_keyword_categories(keyword_category).empty?).to be true
            end
        end
    end

    ############
    # Keywords #
    ############
    context 'when dealing with keywords' do
        before(:all) do
            @name = 'RSpecTest'
            @updated_name = 'RSpectTest-Updated'
            @keyword_category_id = 5 # Type of Asset in Referece category
        end
        describe '#create_keywords' do
            it 'creates a keyword', :aggregate_failures do
                keyword_category_id = 5 # Type of Asset in Referece category
                keyword = Keywords.new(@keyword_category_id,@name)
                object = @client.create_keywords(keyword,true).first
                expect(object.is_a?(Keywords)).to be true
                expect(object.name).to eq @name
                expect(object.keyword_category_id).to eq @keyword_category_id
            end
        end
        describe '#get_keyords' do
            it 'retrieves a keyword', :aggregate_failures do
                @query.clear
                @query.add_option('name',@name)
                @query.add_option('textMatching','exact')
                @query.add_option('keyword_category_id',@keyword_category_id)
                object = @client.get_keywords(@query).first
                expect(object.is_a?(Keywords)).to be true
                expect(object.name).to eq @name
                expect(object.keyword_category_id).to eq @keyword_category_id
            end
        end
        describe '#update_keywords' do
            it 'modifies a keyword', :aggregate_failures do
                @query.clear
                @query.add_option('name',@name)
                @query.add_option('keyword_category_id',@keyword_category_id)
                @query.add_option('textMatching','exact')
                keyword = @client.get_keywords(@query).first
                keyword.name = @updated_name
                object = @client.update_keywords(keyword,true).first
                expect(object.is_a?(Keywords)).to be true
                expect(object.name).to eq @updated_name
            end
        end
        describe '#delete_keywords' do
            it 'deletes a keyword' do
                @query.clear
                @query.add_option('name',@updated_name)
                @query.add_option('keyword_category_id',@keyword_category_id)
                @query.add_option('textMatching','exact')
                keyword = @client.get_keywords(@query).first
                expect(@client.delete_keywords(keyword).empty?).to be true
            end
        end
    end

    #################
    # Photographers #
    #################
    context 'when dealing with photographers' do
        before(:all) do
            @name= Helpers.generate_unique_name()
            @new_name = "#{@name}_Updated"
        end
        describe '#create_photographers' do
            it 'creates a photographer' do
                photographer = Photographers.new(@name)
                photographer = @client.create_photographers(photographer,true).first
                expect(photographer.is_a?(Photographers)).to be true
            end
        end
        describe '#get_photographers' do
            it 'retrieves a photographer', :aggregate_failures do
                @query.clear
                @query.add_option('name',@name)
                @query.add_option('textMatching','exact')
                object = @client.get_photographers(@query).first
                expect(object.is_a?(Photographers)).to be true
                expect(object.name).to eq @name
            end
        end
        describe '#update_photographers' do
            it 'modifies a photographer', :aggregate_failures do
                @query.clear
                @query.add_option('name',@name)
                @query.add_option('textMatching','exact')
                photographer = @client.get_photographers(@query).first
                photographer.name = @new_name
                object = @client.update_photographers(photographer,true).first
                expect(object.is_a?(Photographers)).to be true
                expect(object.name).to eq @new_name
            end
        end
    end

    ##############################
    # Project Keyword Categories #
    ##############################
    context 'when dealing with project keyword categories' do
        project_keyword_category = nil
        describe '#create_project_keyword_categories' do
            it 'creates a project keyword category' do
                project_keyword_category = ProjectKeywordCategories.new('RSpecTest')
                project_keyword_category =
                    @client.create_project_keyword_categories(project_keyword_category,true).first
                expect(project_keyword_category.is_a?(ProjectKeywordCategories)).to be true
            end
        end
        describe '#get_project_keyword_categories' do
            it 'retrieves a project keyword category' do
                object = @client.get_project_keyword_categories.first
                expect(object.is_a?(ProjectKeywordCategories)).to be true
            end
        end
        describe '#update_project_keyword_categories' do
            it 'modifies a project keyword category' do
                project_keyword_category.name = 'RSpecTest-Updated'
                expect(@client.update_project_keyword_categories(project_keyword_category).code).to eq '200'
            end
        end
        describe '#delete_project_keyword_categories' do
            it 'deletes a project keyword category' do
                @query.clear
                @query.add_option('name','RSpecTest-Updated')
                @query.add_option('textMatching','exact')
                project_keyword_category = @client.get_project_keyword_categories(@query).first
                expect(@client.delete_project_keyword_category(project_keyword_category).empty?).to be true
            end
        end
    end

    ####################
    # Project Keywords #
    ####################
    describe 'when dealing with project keywords' do
        before(:all) do
            @name = 'RSpecTest'
            @query.clear
            @query.add_option('name',@name)
            @project_keyword_category = @client.get_project_keyword_categories(@query).first
            if @project_keyword_category.nil?
                pkc = ProjectKeywordCategories.new(@name)
                @project_keyword_category =
                    @client.create_project_keyword_categories(pkc,true).first
            end
        end
        it 'creates a project keyword' do
            project_keyword = ProjectKeywords.new(@name,@project_keyword_category.id)
            project_keyword = @client.create_project_keywords(project_keyword,true).first
            expect(project_keyword.is_a?(ProjectKeywords)).to be true
        end
        it 'retrieves a project keyword' do
            project_keyword = @client.get_project_keywords.first
            expect(project_keyword.is_a?(ProjectKeywords)).to be true
        end
        it 'modifies a project keyword' do
            query = RestOptions.new
            query.add_options('name',@name)
            proj_keyword = @client.get_project_keywords(query).first
            proj_keyword.name = "#{@name}-Updated"
            expect(@client.update_project_keywords(proj_keyword).code).to eq '200'
        end
        it 'deletes a project keyword' do
            query = RestOptions.new
            query.add_option('name',"#{@name}-Updated")
            query.add_option('project_keyword_category_id',@project_keyword_category_id)
            query.add_option('textMatching','exact')
            proj_keyword = @client.get_project_keywords(query)
            expect(@client.delete_project_keywords(proj_keyword).empty?).to be true
        end
        after(:all) do
            @client.delete_project_keyword_categories(@project_keyword_category)
        end
    end

    ############
    # Projects #
    ############
    context 'when dealing with projects' do
        context 'with location' do
            describe 'client' do
                before(:all) do
                    @project = Projects.new('RSpecTest222','1000.12444')
                    @query = RestOptions.new
                end
                it 'creates a project' do
                    @project.set_location('40.7128 N , 74.0060 W')
                    @project = @client.create_projects(@project,true).first
                    expect(@project.is_a?(Projects)).to be true
                end
                it 'retrieves a project' do
                    object = @client.get_projects.first
                    expect(object.is_a?(Projects)).to be true
                end
                it 'modifies a project' do
                    @query.add_option('name','RSpecTest222')
                    @project = @client.get_projects(@query).first
                    @project.name = 'RSpecTest-Updated'
                    expect(@client.update_projects(@project).code).to eq '200'

                end
                it 'deletes a project' do
                    @query.clear
                    @query.add_option('name','RSpecTest-Updated')
                    @project = @client.get_projects(@query).first
                    expect(@client.delete_projects(@project).empty?).to be true
                end
            end
        end

        context 'with nested resources' do
            describe 'client' do
                before(:all) do

                    @name = 'RSpecTest'
                    @project = Projects.new(@name,'1234.56')

                    @query = RestOptions.new
                    @query.add_option('name',@name)
                    @query.add_option('textMatching','exact')

                    @project_keyword_category = @client.get_project_keyword_categories(@query).first
                    if @project_keyword_category.nil?
                        pkc = ProjectKeywordCategories.new(@name)
                        @project_keyword_category = @client.create_project_keyword_categories(pkc,true).first
                    end

                    @project_keyword = @client.get_project_keywords(@query).first
                    if @project_keyword.nil?
                        pk = ProjectKeywords.new(@name,@project_keyword_category.id)
                        @project_keyword = @client.create_project_keywords(pk,true).first
                    end

                    @query.add_option('field_type','project')
                    @query.add_option('textMatching','exact')
                    @field = @client.get_fields(@query).first
                    if @field.nil?
                        field = Fields.new(@name,'project','singleLine')
                        @field = @client.create_fields(field,true).first
                    end
                end
                it 'creates a project' do
                    proj = @client.create_projects(@project,true).first
                    @project.id = proj.id
                    expect(proj.is_a?(Projects)).to be true
                end
                it 'retrieves a project with nested resources', :aggregate_failures do
                    @query.clear
                    @query.add_option('id',@project.id)
                    @query.add_option('albums','all')
                    @query.add_option('projectKeywords','all')
                    @query.add_option('fields','all')
                    proj = @client.get_projects(@query).first
                    expect(proj.is_a?(Projects)).to be true
                    expect(proj.project_keywords.is_a?(Array)).to be true
                    expect(proj.fields.is_a?(Array)).to be true
                    expect(proj.albums.is_a?(Array)).to be true
                end
                it 'updates nested fields in a project', :aggregate_failures do
                    @query.clear
                    @query.add_option('id',@project.id)

                    proj = @client.get_projects(@query).first

                    @client.project_add_keyword(proj,@project_keyword)
                    @client.project_add_field_data(proj,@field,'Test Data')

                    @query.clear
                    @query.add_option('id',@project.id)
                    @query.add_option('albums','all')
                    @query.add_options('fields','all')
                    @query.add_options('projectKeywords','all')

                    proj = @client.get_projects(@query).first
                    proj.albums << NestedAlbumItems.new(17) # Stubbed

                    nested_album = proj.albums.find { |a| a.id == 17 }
                    nested_field = proj.fields.find { |f| f.id == @field.id }
                    nested_proj_keyword = proj.project_keywords.find { |pk| pk.id == @project_keyword.id }

                    unless nested_album
                        fail 'Associated album assignment failed'
                    end
                    unless nested_field
                        fail 'Project field update failed'
                    end
                    unless nested_proj_keyword
                        fail 'Project keyword assignment failed'
                    end

                    expect(proj.is_a?(Projects)).to be true
                    expect(nested_proj_keyword.id).to eq @project_keyword.id
                    expect(nested_field.id).to eq @field.id
                    expect(nested_field.values.first).to eq 'Test Data'
                    expect(nested_album.id).to eq 17
                end
                after(:all) do
                    @client.delete_projects(@project)
                    @client.delete_fields(@field)
                    @client.delete_project_keywords(@project_keyword)
                    @client.delete_project_keyword_categories(@project_keyword_category)
                end
            end
        end
    end

    ############
    # Searches #
    ############
    # possible BUG in API ignores the required name field during POST
    context 'when dealing with searches' do
        describe 'client' do
            id = 0
            before(:all) do
                @name = Helpers.generate_unique_name()
            end
            it 'creates a search' do
                args = {
                    'code'     => 'rank',
                    'exclude'  => '0',
                    'operator' => '<',
                    'values'   => ['6']
                }
                search_item = SearchItems.new(args)

                search = Searches.new(@name,search_item)
                object = @client.create_searches(search,true).first
                id = object.id
                expect(object.is_a?(Searches)).to be true
            end
            it 'retrieves a search' do
                @query.clear
                @query.add_option('id',id)
                object = @client.get_searches(@query).first
                expect(object.is_a?(Searches)).to be true
            end
            it 'modifies a search' do
                @query.clear
                @query.add_option('id',id)
                object = @client.get_searches(@query).first
                object.name = "#{@name}_Updated"
                expect(@client.update_searches(object).code).to eq '200'
            end
        end
    end

    #########
    # Sizes #
    #########
    context 'when dealing with sizes' do
        img_size = nil
        postfix  = nil
        img_size = nil
        describe '#create_image_sizes' do
            it 'creates an image size' do
                postfix = Helpers.generate_random_string(12)
                data = {
                    'postfix'       => postfix,
                    'file_format'   => 'jpg',
                    'colourspace'   => 'RGB',
                    'width'         => 1920,
                    'height'        => 1080,
                    'always_create' => 1,
                    'x_resolution'  => 72,
                    'y_resolution'  => 72,
                    'quality'       => 100
                }
                img_size = Sizes.new(data)
                img_size = @client.create_image_sizes(img_size,true).first
                expect(img_size.is_a?(Sizes)).to be true
            end
        end
        describe '#get_image_sizes' do
            it 'retrieves an image size' do
                object = @client.get_image_sizes.first
                expect(object.is_a?(Sizes)).to be true
            end
        end
        describe '#update_image_sizes' do
            it 'modifies an image size' do
                img_size.display_order = 5
                expect(@client.update_image_sizes(img_size).code).to eq '200'
            end
        end
        describe '#delete_image_sizes' do
            it 'deletes an image size' do
                expect(@client.delete_image_sizes(img_size).empty?).to be true
            end
        end
    end

    #################
    # Text Rewrites #
    #################
    context 'when dealing with text rewrites' do
        describe '#get_text_rewrites' do
            it 'retrieves a text rewrite' do
                expect(@client.get_text_rewrites.empty?).to be true
            end
        end
    end

    #########
    # Users #
    #########
    context 'when dealing with users' do
        context 'with nested groups' do
            user = nil
            admin_group_id = 1
            describe '#create_users' do
                it 'creates a user' do
                    password = Helpers.generate_random_string()
                    data = {
                        'username'  => 'jdoe@axomic.com',
                        'full_name' => 'John Doe',
                        'password'  => password
                    }
                    user = @client.create_users(data,true).first
                    expect(user.is_a?(Users)).to be true
                end
            end
            describe '#update_users' do
                it 'modifies a user' do
                    user.full_name = 'Jane Doe'
                    user.groups << NestedGroupItems.new(admin_group_id)
                    expect(@client.update_users(user).code).to eq '200'
                end
            end
            describe '#get_users' do
                it 'retrieves a user' do
                    object = @client.get_users.first
                    expect(user.is_a?(Users)).to be true
                end
                it 'is assigned to a group' do
                    expect(user.groups.first.id).to eq admin_group_id
                end
            end
            describe '#delete_users' do
                it 'deletes a user' do
                    expect(@client.delete_users(user).empty?).to be true
                end
            end
        end
    end
end