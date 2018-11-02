require_relative 'Version/version'
require_relative 'SmartUpdater'
require_relative 'ArrayClassExtender'
require_relative 'ObjectGenerator'
require_relative 'Authenticator'
require_relative 'FileUploader'
require_relative 'FileReplacer'
require_relative 'RestOptions'
require_relative 'MyLogger'
require_relative 'Generic'
require_relative 'Encoder'
require_relative 'Error'
require_relative 'Finder'
require_relative 'Fetcher'
require_relative 'SQLParser'

require 'net/http'


# Include all the nouns
Dir[File.join(File.dirname(__FILE__),'Nouns','*.rb')].each { |file| require_relative file }

# Include all the CRUD methods
Dir[File.join(File.dirname(__FILE__),'CRUDMethods','*.rb')].each { |file| require_relative file }

# Include all Administrative Functions
Dir[File.join(File.dirname(__FILE__),'AdministrativeFunctions','*.rb')].each { |file| require_relative file }

module OpenAsset

    class RestClient

        # Provides a globally shared singleton logger
        include Logging

        # CRUD Methods
        include Get
        include Post
        include Put
        include Delete

        # Helper Methods
        include Encoder
        include KeywordMover
        include ErrorHandler
        include ArgumentHandler
        include ObjectGenerator
        include ConnectionTester
        include SmartUpdater
        include FileUploader
        include FileReplacer
        include Fetcher

        # Administrative Functions - FILES
        include FileAddKeywords
        include FileAddFieldData
        include AddFilesToAlbum
        include FileMoveFieldDataToKeywordsByAlbum
        include FileMoveFieldDataToKeywordsByProject
        include FileMoveFieldDataToKeywordsByCategory
        include FileMoveKeywordsToFieldByAlbum
        include FileMoveKeywordsToFieldByProject
        include FileMoveKeywordsToFieldByCategory

        # Administrative Functions - PROJECTS
        include ProjectAddKeywords
        include ProjectAddFieldData
        include ProjectMoveFieldDataToKeywords
        include ProjectMoveKeywordsToField
        include AssignHeroImages

        # Administrative Functions - Users/Groups
        include AddUsersToGroups



        # @!parse attr_reader :session, :uri, :gem_version, :oa_version
        attr_reader :session, :uri, :gem_version, :oa_version

        # @!parse attr_accessor :verbose, :outgoing_encoding
        attr_accessor :verbose, :outgoing_encoding

        # Create new instance of the OpenAsset rest client
        #
        # @param client_url [string] Cloud client url
        # @return [RestClient object]
        #
        # @example
        #         rest_client = OpenAsset::RestClient.new('se1.openasset.com')
        def initialize(client_url,un='',pw='')

            @authenticator = Authenticator.get_instance(client_url,un,pw)
            @sql           = SQLParser.new
            @finder        = Finder.new
            @session       = @authenticator.get_session
            @uri           = @authenticator.uri
            @oa_version    = @authenticator.get_oa_version
            @gem_version   = Openasset::VERSION  # Not to be confused with OA codebase version
            @verbose       = false
            @incoming_encoding = 'utf-8' # => Assume utf-8 unless web server specifies otherwise
            @outgoing_encoding = 'utf-8'

        end

        private
        def handle_get_request(uri,query_obj,with_nested_resources)
            results = []
            end_point = uri.request_uri.split(/\//).last
            if query_obj.is_a?(String) # Assumed SQL statement
                expressions = @sql.parse(query_obj,end_point) # Parse SQL
                if expressions.nil?
                    logger.error('SQL parsing error occured')
                    return
                end
                objects = get_objects(uri) # Get all objects in batches - private method
                results = @finder.find_matches(expressions,objects) # Returns matches
            else # Assumed RestOptions object
                results = get(uri,query_obj,with_nested_resources)
            end
            results
        end

        public
        #########################
        #                       #
        #   Session Management  #
        #                       #
        #########################

        # Destroys current session
        #
        # @return [nil] Does not return anything.
        #
        # @example
        #           rest_client.kill_session()
        def kill_session
           @session = @authenticator.kill_session
        end

        # Generates a new session
        #
        # @return [nil] Does not return anything.
        #
        # @example
        #           rest_client.get_session()
        def get_session
            @session = @authenticator.get_session
        end

        # Destroys current session and Generates new one
        #
        # @return [nil] Does not return anything.
        #
        # @example
        #          rest_client.renew_session()
        def renew_session
            kill_session
            get_session
        end

        ####################################################
        #                                                  #
        #  Retrieve, Create, Modify, and Delete Resources  #
        #                                                  #
        ####################################################


        #################
        #               #
        # ACCESS LEVELS #
        #               #
        #################

        # Retrieves Access Levels.
        #
        # @param query_obj [RestOptions Object] Takes a RestOptions object containing query string (Optional)
        # @return [Array] Returns an array of AccessLevels objects.
        #
        # @example
        #          rest_client.get_access_levels()
        #          rest_client.get_access_levels(rest_options_object)
        def get_access_levels(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/AccessLevels")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_access_level :get_access_levels

        ##########
        #        #
        # ALBUMS #
        #        #
        ##########

        # Retrieves Albums.
        #
        # @param query_obj [RestOptions Object] Takes a RestOptions object containing query string (Optional)
        # @return [Array] Returns an array of Albums objects.
        #
        # @example
        #          rest_client.get_albums()
        #          rest_client.get_albums(rest_options_object)
        def get_albums(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/Albums")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_album :get_albums

        # Create Albums.
        #
        # @param data [Single Albums Object, Array of Albums Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after updating object
        # @return [JSON object] HTTP response JSON object. Returns an Albums objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.create_albums(albums_obj)
        #          rest_client.create_albums(albums_obj_array)
        #            rest_client.create_albums(albums_obj,true)
        #          rest_client.create_albums(albums_obj_array,true)
        def create_albums(data=nil,generate_objects=false)
            uri = URI.parse(@uri + '/Albums')
            post(uri,data,generate_objects)
        end
        alias :create_album :create_albums

        # Modify Albums.
        #
        # @param data [Single Albums Object, Array of Albums Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after updating object
        # @return [JSON object] HTTP response JSON object. Returns an Albums objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.update_albums(albums_obj)
        #          rest_client.update_albums(albums_obj,true)
        #          rest_client.update_albums(albums_obj_array)
        #          rest_client.update_albums(albums_obj_array,true)
        def update_albums(data=nil,generate_objects=false)
            uri = URI.parse(@uri + '/Albums')
            put(uri,data,generate_objects)
        end
        alias :update_album :update_albums

        # Delete Albums.
        #
        # @param data [Single Albums Object, Array of Albums Objects, Integer, String, Integer Array, Numeric String Array (Required)
        # @return [JSON object] HTTP response JSON object.
        #
        # @example
        #          rest_client.delete_albums(albums_obj)
        #          rest_client.delete_albums(albums_objects_array)
        #          rest_client.delete_albums([1,2,3])
        #          rest_client.delete_albums(['1','2','3'])
        #          rest_client.delete_albums(1)
        #          rest_client.delete_albums('1')
        def delete_albums(data=nil)
            uri = URI.parse(@uri + '/Albums')
            delete(uri,data)
        end
        alias :delete_album :delete_albums

        ####################
        #                  #
        # ALTERNATE STORES #
        #                  #
        ####################

        # Retrieves Alternate Stores.
        #
        # @param query_obj [RestOptions Object] Takes a RestOptions object containing query string (Optional)
        # @return [Array] Returns an array of AlternateStores objects.
        #
        # @example
        #          rest_client.get_alternate_stores()
        #          rest_client.get_alternate_stores(rest_options_object)
        def get_alternate_stores(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/AlternateStores")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_alternate_store :get_alternate_stores

        #################
        #               #
        # ASPECT RATIOS #
        #               #
        #################

        # Retrieves Aspect Ratios.
        #
        # @param query_obj [RestOptions Object] Takes a RestOptions object containing query string (Optional)
        # @return [Array] Returns an array of AspectRatios objects.
        #
        # @example
        #          rest_client.get_aspect_ratios()
        #          rest_client.get_aspect_ratios(rest_options_object)
        def get_aspect_ratios(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/AspectRatios")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_aspect_ratio :get_aspect_ratios

        ##############
        #            #
        # CATEGORIES #
        #            #
        ##############

        # Retrieves system Categories (not keyword categories).
        #
        # @param query_obj [RestOptions Object] Takes a RestOptions object containing query string (Optional)
        # @return [Array] Returns an array of Categories objects.
        #
        # @example
        #          rest_client.get_categories()
        #          rest_client.get_categories(rest_options_object)
        def get_categories(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/Categories")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_category :get_categories

        # Modify system Categories.
        #
        # @param data [Single Categories Object, Array of Categories Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after updating object
        # @return [JSON object] HTTP response JSON object. Returns a Categories objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.update_categories(categories_obj)
        #          rest_client.update_categories(categories_obj,true)
        #          rest_client.update_categories(categories_obj_array)
        #          rest_client.update_categories(categories_obj_array,true)
        def update_categories(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/Categories")
            put(uri,data,generate_objects)
        end
        alias :update_category :update_categories

        #####################
        #                   #
        # COPYRIGHT HOLDERS #
        #                   #
        #####################

        # Retrieves CopyrightHolders.
        #
        # @param query_obj [RestOptions Object] Takes a RestOptions object containing query string (Optional)
        # @return [Array] Returns an array of CopyrightHolders objects.
        #
        # @example
        #          rest_client.get_copyright_holders()
        #          rest_client.get_copyright_holders(rest_options_object)
        def get_copyright_holders(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/CopyrightHolders")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_copyright_holder :get_copyright_holders

        # Create CopyrightHoloders.
        #
        # @param data [Single CopyrightPolicies Object, Array of CopyrightPolicies Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after object creation
        # @return [JSON object] HTTP response JSON object. Returns a CopyrightHolders objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.create_copyright_holders(copyright_holders_obj)
        #          rest_client.create_copyright_holders(copyright_holders_obj_array)
        #          rest_client.create_copyright_holders(copyright_holders_obj,true)
        #          rest_client.create_copyright_holders(copyright_holders_obj_array,true)
        def create_copyright_holders(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/CopyrightHolders")
            post(uri,data,generate_objects)
        end
        alias :create_copyright_holder :create_copyright_holders

        # Modify CopyrightHolders.
        #
        # @param data [Single CopyrightHolders Object, Array of CopyrightHoloders Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after updating object
        # @return [JSON object] HTTP response JSON object. Returns a CopyrightHolders objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.update_copyright_holders(copyright_holders_obj)
        #          rest_client.update_copyright_holders(copyright_holders_obj,true)
        #          rest_client.update_copyright_holders(copyright_holders_obj_array)
        #          rest_client.update_copyright_holders(copyright_holders_obj_array,true)
        def update_copyright_holders(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/CopyrightHolders")
            put(uri,data,generate_objects)
        end
        alias :update_copyright_holder :update_copyright_holders

        ######################
        #                    #
        # COPYRIGHT POLICIES #
        #                    #
        ######################

        # Retrieves CopyrightPolicies.
        #
        # @param query_obj [RestOptions Object] Takes a RestOptions object containing query string (Optional)
        # @return [Array] Returns an array of CopyrightPolicies objects.
        #
        # @example
        #          rest_client.get_copyright_policies()
        #          rest_client.get_copyright_policies(rest_options_object)
        def get_copyright_policies(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/CopyrightPolicies")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_copyright_policy :get_copyright_policies

        # Create CopyrightPolicies.
        #
        # @param data [Single CopyrightPolicies Object, Array of CopyrightPolicies Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after object creation
        # @return [JSON object] HTTP response JSON object. Returns a CopyrightPolicies objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.create_copyright_policies(copyright_policies_obj)
        #          rest_client.create_copyright_policies(copyright_policies_obj_array)
        #          rest_client.create_copyright_policies(copyright_policies_obj,true)
        #          rest_client.create_copyright_policies(copyright_policies_obj_array,true)
        def create_copyright_policies(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/CopyrightPolicies")
            post(uri,data,generate_objects)
        end
        alias :create_copyright_policy :create_copyright_policies

        # Modify CopyrightPolicies.
        #
        # @param data [Single CopyrightPolicies Object, Array of CopyrightPolicies Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after updating object
        # @return [JSON object] HTTP response JSON object. Returns a CopyrightPolicies objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.update_copyright_policies(copyright_policies_obj)
        #          rest_client.update_copyright_policies(copyright_policies_obj,true)
        #          rest_client.update_copyright_policies(copyright_policies_obj_array)
        #          rest_client.update_copyright_policies(copyright_policies_obj_array,true)
        def update_copyright_policies(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/CopyrightPolicies")
            put(uri,data,generate_objects)
        end
        alias :update_copyright_policy :update_copyright_policies

        # Disables CopyrightPolicies.
        #
        # @param data [Single CopyrightPolicies Object, CopyrightPolicies Objects Array, Integer, Integer Array, Numeric String, Numeric String Array] (Required)
        # @return [JSON object] HTTP response JSON object.
        #
        # @example
        #          rest_client.delete_copyright_policies(copyright_policies_obj)
        #          rest_client.delete_copyright_policies(copyright_policies_obj_array)
        #          rest_client.delete_copyright_policies([1,2,3])
        #          rest_client.delete_copyright_policies(['1','2','3'])
        #          rest_client.delete_copyright_policies(1)
        #          rest_client.delete_copyright_policies('1')
        def delete_copyright_policies(data=nil)
            uri = URI.parse(@uri + "/CopyrightPolicies")
            delete(uri,data)
        end
        alias :delete_copyright_policy :delete_copyright_policies

        #####################
        #                   #
        # DATA INTEGRATIONS #
        #                   #
        #####################

        # Retrieves DataIntegrations.
        #
        # @param query_obj [RestOptions Object] Takes a RestOptions object containing query string (Optional)
        # @return [Array] Returns an array of DataIntegrations objects.
        #
        # @example
        #          rest_client.get_data_integrations()
        #          rest_client.get_data_integrations(rest_options_object)
        def get_data_integrations(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/DataIntegrations")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_data_integration :get_data_integrations


        ##########
        #        #
        # FIELDS #
        #        #
        ##########

        # Retrieves Fields.
        #
        # @param query_obj [RestOptions Object] Takes a RestOptions object containing query string (Optional)
        # @return [Array] Returns an array of Fields objects.
        #
        # @example
        #          rest_client.get_fields()
        #          rest_client.get_fields(rest_options_object)
        def get_fields(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/Fields")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_field :get_fields

        # Create fields.
        #
        # @param data [Single Fields Object, Array of Fields Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after object creation
        # @return [JSON object] HTTP response JSON object. Returns a Fields objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.create_fields(fields_obj)
        #          rest_client.create_fields(fields_obj_array)
        #          rest_client.create_fields(fields_obj,true)
        #          rest_client.create_fields(fields_obj_array,true)
        def create_fields(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/Fields")
            post(uri,data,generate_objects)
        end
        alias :create_field :create_fields

        # Modify fields.
        #
        # @param data [Single Fields Object, Array of Fields Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after updating object
        # @return [JSON object] HTTP response JSON object. Returns a Fields objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.update_fields(fields_obj)
        #          rest_client.update_fields(fields_obj,true)
        #          rest_client.update_fields(fields_obj_array)
        #          rest_client.update_fields(fields_obj_array,true)
        def update_fields(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/Fields")
            put(uri,data,generate_objects)
        end
        alias :update_field :update_fields

        # Disable fields.
        #
        # @param data [Single Fields Object, Array of Fields Objects, Integer, Integer Array, Numeric String, Numeric String Array]
        # @return [JSON object] HTTP response JSON object.
        #
        # @example
        #          rest_client.delete_fields(fields_obj)
        #          rest_client.delete_fields(fields_obj_array)
        #          rest_client.delete_fields([1,2,3])
        #          rest_client.delete_fields(['1','2','3'])
        #          rest_client.delete_fields(1)
        #          rest_client.delete_fields('1')
        def delete_fields(data=nil)
            uri = URI.parse(@uri + "/Fields")
            delete(uri,data)
        end
        alias :delete_field :delete_fields

        ########################
        #                      #
        # FIELD LOOKUP STRINGS #
        #                      #
        ########################

        # Retrieves options for Fixed Suggestion, Suggestion, and Option field types.
        #
        # @param field [Fields Object, Hash, String, Integer] Argument must specify the field id (Required)
        # @param query_obj[RestOptions Object] Specify query parameters string (Optional)
        # @return [Array] Array of FieldLookupStrings.
        #
        # @example
        #          rest_client.get_field_lookup_strings()
        #          rest_client.get_field_lookup_strings(rest_options_object)
        def get_field_lookup_strings(field=nil,query_obj=nil,with_nested_resources=false)
            id = Validator.validate_field_lookup_string_arg(field)

            uri = URI.parse(@uri + "/Fields" + "/#{id}" + "/FieldLookupStrings")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_field_lookup_string :get_field_lookup_strings

        # creates options for Fixed Suggestion, Suggestion, and Option field types.
        #
        # @param field [Fields Object, Hash, String, Integer] Argument must specify the field id (Required)
        # @param data [Single FieldLookupString Object, Array of FieldLookupString Objects]
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after object creation
        # @return [JSON object] HTTP response JSON object. Returns Array of FieldLookupStrings objects if generate_objects flag is set
        #
        # @example
        #          rest_client.create_field_lookup_strings(field_obj,field_lookup_strings_obj)
        #          rest_client.create_field_lookup_strings(field_obj,field_lookup_strings_obj,true)
        #          rest_client.create_field_lookup_strings(field_obj,field_lookup_strings_obj_array)
        #          rest_client.create_field_lookup_strings(field_obj,field_lookup_strings_obj_array,true)
        def create_field_lookup_strings(field=nil,data=nil,generate_objects=false)
            id = Validator.validate_field_lookup_string_arg(field)

            uri = URI.parse(@uri + "/Fields" + "/#{id}" + "/FieldLookupStrings")
            post(uri,data,generate_objects)
        end
        alias :create_field_lookup_string :create_field_lookup_strings

        # Modifies options for Fixed Suggestion, Suggestion, and Option field types.
        #
        # @param field [Fields Object, Hash, String, Integer] Argument must specify the field id (Required)
        # @param data [Single FieldLookupString Object, Array of FieldLookupString Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after updating object
        # @return [JSON object] HTTP response JSON object. Returns Array of FieldLookupStrings objects if generate_objects flag is set
        #
        # @example
        #          rest_client.update_field_lookup_strings(field_obj,field_lookup_strings_obj)
        #          rest_client.update_field_lookup_strings(field_obj,field_lookup_strings_obj,true)
        #          rest_client.update_field_lookup_strings(field_obj,field_lookup_strings_obj_array)
        #          rest_client.update_field_lookup_strings(field_obj,field_lookup_strings_obj_array,true)
        def update_field_lookup_strings(field=nil,data=nil,generate_objects=false)
            id = Validator.validate_field_lookup_string_arg(field)

            uri = URI.parse(@uri + "/Fields" + "/#{id}" + "/FieldLookupStrings")
            put(uri,data,generate_objects)
        end
        alias :update_field_lookup_string :update_field_lookup_strings

        # Delete an item and/or option for Fixed Suggestion, Suggestion, and Option field types.
        #
        # @param field [Fields Object, String, Integer] Argument must specify the field id
        # @param data [Single FieldLookupString Object, Array of FieldLookupString Objects, Integer, Integer Array, Numeric String, Numeric String Array]
        # @return [JSON object] HTTP response JSON object.
        #
        # @example
        #          rest_client.delete_field_lookup_strings(field_obj, field_lookup_strings_obj)
        #          rest_client.delete_field_lookup_strings(field_obj, field_lookup_strings_obj_array)
        #          rest_client.delete_field_lookup_strings(field_obj, [1,2,3])
        #          rest_client.delete_field_lookup_strings(field_obj, ['1','2','3'])
        #          rest_client.delete_field_lookup_strings(field_obj, 1)
        #          rest_client.delete_field_lookup_strings(field_obj, '1')
        def delete_field_lookup_strings(field=nil,data=nil)

            id = Validator.validate_field_lookup_string_arg(field)

            uri = URI.parse(@uri + "/Fields" + "/#{id}" + "/FieldLookupStrings")
            delete(uri,data) #data parameter validated in private delete method
        end
        alias :delete_field_lookup_string :delete_field_lookup_strings

        #########
        #       #
        # Files #
        #       #
        #########

        # Retrieves Files objects with ALL nested resources - including their nested image sizes - from OpenAsset.
        #
        # @param query_obj [RestOptions Object] Takes a RestOptions object containing query string (Optional)
        # @return [Array] Returns an array of Files objects.
        #
        # @example
        #          rest_client.get_files => Gets 10 files w/o nested resources
        #          rest_client.get_files(rest_options_object) => Gets file limit set in RestOption w/o nested resources
        #          rest_client.get_files(rest_options_object,true) => Gets file limit set in RestOption with nested resources
        #          rest_client.get_files(nil,true) => Gets 10 files including all nested fields and image sizes
        def get_files(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/Files")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_file :get_files

        # Uploads a file to OpenAsset.
        #
        # @param file [String] the path to the file being uploaded
        # @param category [Categories Object,String,Integer] containing Target Category ID in OpenAsset (Required)
        # @param project [Projects Object, String, Integer] Project ID in OpenAsset (Specified only when Category is project based)
        # @return [JSON Object] HTTP response JSON object. Returns Files objects array if generate_objects flag is set
        #
        # FOR PROJECT UPLOADS
        # @example
        #          rest_client.upload_file('/path/to/file', category_obj, project_obj)
        #          rest_client.upload_file('/path/to/file','2','10')
        #          rest_client.upload_file('/path/to/file', 2, 10)
        #          rest_client.upload_file('/path/to/file', category_obj, project_obj, true)
        #          rest_client.upload_file('/path/to/file','2','10', true)
        #          rest_client.upload_file('/path/to/file', 2, 10, true)
        #
        #
        # FOR REFERENCE UPLOADS
        # @example
        #          rest_client.upload_file('/path/to/file', category_obj)
        #          rest_client.upload_file('/path/to/file','2')
        #          rest_client.upload_file('/path/to/file', 2,)
        #          rest_client.upload_file('/path/to/file', category_obj, nil, true)
        #          rest_client.upload_file('/path/to/file','2', nil, true)
        #          rest_client.upload_file('/path/to/file', 2, nil, true)
        def upload_file(file=nil, category=nil, project=nil, generate_objects=false,read_timeout=600)
            __upload_file(file, category, project, generate_objects,read_timeout)
        end

        # Replace a file in OpenAsset.
        #
        # @param original_file_object [Single Files Object] (Required) File Object in OA
        # @param replacement_file_path [String] (Required)
        # @param retain_original_filename_in_oa [Boolean] (Optional, Default => false)
        # @param generate_objects [Boolean] Return an array of Files or JSON objects in response body (Optional, Default => false)
        # @return [JSON object or Files Object Array ]. Returns Files objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.replace_file(file_obj,'C:\Users\root\Pictures\new_img.jpg')
        #          rest_client.replace_file(file_obj,'C:\Users\root\Pictures\new_img.jpg',true,true)
        #          rest_client.replace_file(file_obj,'C:\Users\root\Pictures\new_img.jpg',false,false)
        #          rest_client.replace_file(file_obj,'C:\Users\root\Pictures\new_img.jpg',false,true)
        #          rest_client.replace_file(file_obj,'C:\Users\root\Pictures\new_img.jpg',true,false)
        def replace_file(original_file_object=nil,
                         replacement_file_path='',
                         retain_original_filename_in_oa=false,
                         generate_objects=false)

            __replace_file(original_file_object,
                         replacement_file_path,
                         retain_original_filename_in_oa,
                         generate_objects)
        end

        # Add files to album(s).
        #
        # @param albums [Albums Objects, Integer, String] (Required)
        # @param files [Files Objects, Integer, String] (Required)
        # @return [Boolean].
        #
        # @example
        #          rest_client.add_files_to_album(album_object,file_object)
        #          rest_client.add_files_to_album(album_objects_array,file_objects_array)
        #          rest_client.add_files_to_album('917','1,2,3,4,5,6') (Add files to album id 917)
        #          rest_client.add_files_to_album([917,918],[1,2,3,4,5,6]) (Add files to albums mutliple albums)
        def add_files_to_album(albums=nil,files=nil)
            __add_files_to_album(albums,files)
        end
        alias :add_files_to_albums :add_files_to_album
        alias :add_file_to_albums :add_files_to_album
        alias :add_file_to_album :add_files_to_albums

        # Add Users to group(s).
        #
        # @param groups [Groups Objects, Array of Groups objects] (Required)
        # @param users [Users Objects, Array of Users objects] (Required)
        # @return [Boolean].
        #
        # @example
        #          rest_client.add_users_to_groups(groups_object,users_object) (Add one user to one group)
        #          rest_client.add_users_to_groups(groups_objects_array,users_objects_array) (Add multiple users to multiple groups)
        #          rest_client.add_users_to_groups(groups_object,users_objects_array) (Add multiple users to one group)
        #          rest_client.add_users_to_groups(groups_objects_array,users_object) (Add a user to mutliple groups)
        def add_users_to_groups(groups=nil,users=nil)
            __add_users_to_groups(groups,users)
        end
        alias :add_user_to_group :add_users_to_groups
        alias :add_users_to_group :add_users_to_groups
        alias :add_user_to_groups :add_users_to_groups

        # Download Files.
        #
        # @param files [Single Files Object, Array of Files Objects] (Required)
        # @param image_size [Integer, String] (Accepts image size id or postfix string:
        #                     Defaults to '1' => original image size id)
        # @param download_location [String] (Default: Creates folder called Rest_Downloads in the current directory.)
        # @return [nil].
        #
        # @example
        #          rest_client.download_files(File_object)
        #          rest_client.download_files(File_objects_array)
        #          rest_client.download_files(File_object,'C:\Folder\Path\Specified')
        #          rest_client.download_files(File_objects_array,'C:\Folder\Path\Specified')
        def download_files(files=nil,image_size='1',download_location='./Rest_Downloads')
            # Put single files objects in an array for easy downloading with
            # the Array class' DownloadHelper module
            files = [files]  unless files.is_a?(Array)

            files.download(image_size,download_location)
        end
        alias :download_file :download_files

        # Update Files.
        #
        # @param data [Single Files Object, Array of Files Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after updating object
        # @return [JSON object] HTTP response JSON object. Returns Files objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.update_files(files_obj)
        #          rest_client.update_files(files_obj,true)
        #          rest_client.update_files(files_obj_array)
        #          rest_client.update_files(files_obj_array,true)
        def update_files(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/Files")
            put(uri,data,generate_objects)
        end
        alias :update_file :update_files

        # Delete Files.
        #
        # @param data [Single Files Object, Array of Files Objects, Integer, Integer Array, Numeric String, Numeric String Array] (Required)
        # @return [JSON object] HTTP response JSON object.
        #
        # @example
        #          rest_client.delete_files(files_obj)
        #          rest_client.delete_files(files_obj_array)
        #          rest_client.delete_files([1,2,3])
        #          rest_client.delete_files(['1','2','3'])
        #          rest_client.delete_files(1)
        #          rest_client.delete_files('1')
        def delete_files(data=nil)
            uri = URI.parse(@uri + "/Files")
            delete(uri,data)
        end
        alias :delete_file :delete_files

        ##########
        #        #
        # GROUPS #
        #        #
        ##########

        # Retrieves Groups.
        #
        # @param query_obj[RestOptions Object] Specify query parameters string (Optional)
        # @return [JSON object] Group objects array.
        #
        # @example
        #          rest_client.get_groups()
        #          rest_client.get_groups(rest_options_object)
        def get_groups(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/Groups")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_group :get_groups

        # Create Groups.
        #
        # @param data [Single Groups Object, Array of Groups Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after object creation
        # @return [JSON object] HTTP response JSON object. Returns Groups objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.create_groups(groups_obj)
        #          rest_client.create_groups(groups_obj,true)
        #          rest_client.create_groups(groups_obj_array)
        #          rest_client.create_groups(groups_obj_array,true)
        def create_groups(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/Groups")
            post(uri,data,generate_objects)
        end
        alias :create_group :create_groups

        # Update Groups.
        #
        # @param data [Single Groups Object, Array of Groups Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after object creation
        # @return [JSON object] HTTP response JSON object. Returns Groups objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.update_groups(groups_obj)
        #          rest_client.update_groups(groups_obj,true)
        #          rest_client.update_groups(groups_obj_array)
        #          rest_client.update_groups(groups_obj_array,true)
        def update_groups(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/Groups")
            put(uri,data,generate_objects)
        end
        alias :update_group :update_groups

        # Delete Groups.
        #
        # @param data [Single Groups Object, Array of Groups Objects, Integer, Integer Array, Numeric String, Numeric String Array] (Required)
        # @return [JSON object] HTTP response JSON object.
        #
        # @example
        #          rest_client.delete_groups(users_obj)
        #          rest_client.delete_groups(users_obj_array)
        #          rest_client.delete_groups([1,2,3])
        #          rest_client.delete_groups(['1','2','3'])
        #          rest_client.delete_groups(1)
        #          rest_client.delete_groups('1')
        def delete_groups(data=nil)
            uri = URI.parse(@uri + "/Groups")
            delete(uri,data)
        end
        alias :delete_group :delete_groups

        ############
        #          #
        # KEYWORDS #
        #          #
        ############

        # Retrieves file keywords.
        #
        # @param query_obj[RestOptions Object] Specify query parameters string (Optional)
        # @return [Array] Array of Keywords objects.
        #
        # @example
        #          rest_client.get_keywords()
        #          rest_client.get_keywords(rest_options_object)
        def get_keywords(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/Keywords")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_keyword :get_keywords

        # Create new file Keywords in OpenAsset.
        #
        # @param data [Single Keywords Object, Array of Keywords Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after object creation
        # @return [JSON object] HTTP response JSON object. Returns Keywords objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.create_keywords(keywords_obj)
        #          rest_client.create_keywords(keywords_obj_array)
        #          rest_client.create_keywords(keywords_obj,true)
        #          rest_client.create_keywords(keywords_obj_array,true)
        def create_keywords(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/Keywords")
            post(uri,data,generate_objects)
        end
        alias :create_keyword :create_keywords

        # Modify file Keywords.
        #
        # @param data [Single Keywords Object, Array of Keywords Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after updating object
        # @return [JSON object] HTTP response JSON object. Returns Keywords objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.update_keywords(keywords_obj)
        #          rest_client.update_keywords(keywords_obj,true)
        #          rest_client.update_keywords(keywords_obj_array)
        #          rest_client.update_keywords(keywords_obj_array,true)
        def update_keywords(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/Keywords")
            put(uri,data,generate_objects)
        end
        alias :update_keyword :update_keywords

        # Delete Keywords.
        #
        # @param data [Single Keywords Object, Array of Keywords Objects, Integer, Integer Array, Numeric String, Numeric String Array] (Required)
        # @return [JSON object] HTTP response JSON object.
        #
        # @example
        #          rest_client.delete_keywords(keywords_obj)
        #          rest_client.delete_keywords(keywords_obj_array)
        #          rest_client.delete_keywords([1,2,3])
        #          rest_client.delete_keywords(['1','2','3'])
        #          rest_client.delete_keywords(1)
        #          rest_client.delete_keywords('1')
        def delete_keywords(data=nil)
            uri = URI.parse(@uri + "/Keywords")
            delete(uri,data)
        end
        alias :delete_keyword :delete_keywords

        ######################
        #                    #
        # KEYWORD CATEGORIES #
        #                    #
        ######################

        # Retrieve file keyword categories.
        #
        # @param query_obj[RestOptions Object] Specify query parameters string (Optional)
        # @return [Array] Array of KeywordCategories objects.
        #
        # @example
        #          rest_client.get_keyword_categories()
        #          rest_client.get_keyword_categories(rest_options_object)
        def get_keyword_categories(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/KeywordCategories")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_keyword_category :get_keyword_categories

        # Create file keyword categories.
        #
        # @param data [Single KeywordCategories Object, Array of KeywordCategories Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after object creation
        # @return [JSON object] HTTP response JSON object. Returns KeywordCategories objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.create_keyword_categories(keyword_categories_obj)
        #          rest_client.create_keyword_categories(keyword_categories_obj_array)
        #          rest_client.create_keyword_categories(keyword_categories_obj,true)
        #          rest_client.create_keyword_categories(keyword_categories_obj_array,true)
        def create_keyword_categories(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/KeywordCategories")
            post(uri,data,generate_objects)
        end
        alias :create_keyword_category :create_keyword_categories

        # Modify file keyword categories.
        #
        # @param data [Single KeywordCategories Object, Array of KeywordCategories Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after updating object
        # @return [JSON object] HTTP response JSON object.. Returns KeywordCategories objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.update_keyword_categories(keyword_categories_obj)
        #          rest_client.update_keyword_categories(keyword_categories_obj,true)
        #          rest_client.update_keyword_categories(keyword_categories_obj_array)
        #          rest_client.update_keyword_categories(keyword_categories_obj_array,true)
        def update_keyword_categories(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/KeywordCategories")
            put(uri,data,generate_objects)
        end
        alias :update_keyword_category :update_keyword_categories

        # Delete Keyword Categories.
        #
        # @param data [Single KeywordCategories Object, KeywordCategories Objects Array, Integer, Integer Array, Numeric String, Numeric String Array] (Required)
        # @return [JSON object] HTTP response JSON object.
        #
        # @example
        #          rest_client.delete_keyword_categories(keyword_categories_obj)
        #          rest_client.delete_keyword_categories(keyword_categories_obj_array)
        #          rest_client.delete_keyword_categories([1,2,3])
        #          rest_client.delete_keyword_categories(['1','2','3'])
        #          rest_client.delete_keyword_categories(1)
        #          rest_client.delete_keyword_categories('1')
        def delete_keyword_categories(data=nil)
            uri = URI.parse(@uri + "/KeywordCategories")
            delete(uri,data)
        end
        alias :delete_keyword_category :delete_keyword_categories

        #################
        #               #
        # PHOTOGRAPHERS #
        #               #
        #################

        # Retrieve photographers.
        #
        # @param query_obj[RestOptions Object] Specify query parameters string (Optional)
        # @return [Array] Array of Photographers objects.
        #
        # @example
        #          rest_client.get_photographers()
        #          rest_client.get_photographers(rest_options_object)
        def get_photographers(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/Photographers")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_photographer :get_photographers

        # Create Photographers.
        #
        # @param data [Single Photographers Object, Array of Photographers Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after object creation
        # @return [JSON object] HTTP response JSON object. Returns Photographers objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.create_photographers(photographers_obj)
        #          rest_client.create_photographers(photographers_obj,true)
        #          rest_client.create_photographers(photographers_obj_array)
        #          rest_client.create_photographers(photographers_obj_array,true)
        def create_photographers(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/Photographers")
            post(uri,data,generate_objects)
        end
        alias :create_photographer :create_photographers

        # Modify Photographers.
        #
        # @param data [Single Photographers Object, Array of Photographers Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after updating object
        # @return [JSON object] HTTP response JSON object. Returns Photographers objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.update_photographers(photographers_obj)
        #          rest_client.update_photographers(photographers_obj,true)
        #          rest_client.update_photographers(photographers_obj_array)
        #          rest_client.update_photographers(photographers_obj_array,true)
        def update_photographers(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/Photographers")
            put(uri,data,generate_objects)
        end
        alias :update_photographer :update_photographers

        ############
        #          #
        # PROJECTS #
        #          #
        ############

        # Retrieve projects
        #
        # @param query_obj[RestOptions Object] Specify query parameters string (Optional)
        # @return [Array] Array of Projects objects.
        #
        # @example
        #          rest_client.get_projects()
        #          rest_client.get_projects(rest_options_object)
        def get_projects(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/Projects")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_project :get_projects

        # Create Projects.
        #
        # @param data [Single Projects Object, Array of Projects Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after object creation
        # @return [JSON object] HTTP response JSON object. Returns Projects objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.create_projects(projects_obj)
        #          rest_client.create_projects(projects_obj,true)
        #          rest_client.create_projects(projects_obj_array)
        #          rest_client.create_projects(projects_obj_array,true)
        def create_projects(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/Projects")
            post(uri,data,generate_objects)
        end
        alias :create_project :create_projects

        # Modify Projects.
        #
        # @param data [Single Projects Object, Array of Projects Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after updating object
        # @return [JSON object] HTTP response JSON object. Returns Projects objects array if generate_objects flag is set
        #
        #
        # @example
        #          rest_client.update_projects(projects_obj)
        #          rest_client.update_projects(projects_obj,true)
        #          rest_client.update_projects(projects_obj_array)
        #          rest_client.update_projects(projects_obj_array,true)
        def update_projects(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/Projects")
            put(uri,data,generate_objects)
        end
        alias :update_project :update_projects

        # Delete Projects.
        #
        # @param data [Single KProjects Object, Array of Projects Objects, Integer, Integer Array, Numeric String, Numeric String Array] (Required)
        # @return [JSON object] HTTP response JSON object.
        #
        # @example
        #          rest_client.delete_projects(projects_obj)
        #          rest_client.delete_projects(projects_obj_array)
        #          rest_client.delete_projects([1,2,3])
        #          rest_client.delete_projects(['1','2','3'])
        #          rest_client.delete_projects(1)
        #          rest_client.delete_projects('1')
        def delete_projects(data=nil)
            uri = URI.parse(@uri + "/Projects")
            delete(uri,data)
        end
        alias :delete_project :delete_projects

        ####################
        #                  #
        # PROJECT KEYWORDS #
        #                  #
        ####################

        # Retrieve project keywords.
        #
        # @param query_obj[RestOptions Object] Specify query parameters string (Optional)
        # @return [Array] Array of ProjectKeywords objects.
        #
        # @example
        #          rest_client.get_project_keywords()
        #          rest_client.get_project_keywords(rest_options_object)
        def get_project_keywords(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/ProjectKeywords")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_project_keyword :get_project_keywords

        # Create Project Keywords.
        #
        # @param data [Single ProjectKeywords Object, Array of ProjectKeywords Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after object creation
        # @return [JSON object] HTTP response JSON object. Returns ProjectKeywords objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.create_project_keywords(project_keywords_obj)
        #          rest_client.create_project_keywords(project_keywords_obj,true)
        #          rest_client.create_project_keywords(project_keywords_obj_array)
        #          rest_client.create_project_keywords(project_keywords_obj_array,true)
        def create_project_keywords(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/ProjectKeywords")
            post(uri,data,generate_objects)
        end
        alias :create_project_keyword :create_project_keywords

        # Modify Project Keywords.
        #
        # @param data [Single ProjectKeywords Object, Array of ProjectKeywords Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after updating object
        # @return [JSON object] HTTP response JSON object. Returns ProjectKeywords objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.update_project_keywords(project_keywords_obj)
        #          rest_client.update_project_keywords(project_keywords_obj,true)
        #          rest_client.update_project_keywords(project_keywords_obj_array)
        #          rest_client.update_project_keywords(project_keywords_obj_array,true)
        def update_project_keywords(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/ProjectKeywords")
            put(uri,data,generate_objects)
        end
        alias :update_project_keyword :update_project_keywords

        # Delete Project Keywords.
        #
        # @param data [Single ProjectKeywords Object, Array of ProjectKeywords Objects, Integer, Integer Array, Numeric String, Numeric String Array] (Required)
        # @return [JSON object] HTTP response JSON object.
        #
        # @example
        #          rest_client.delete_project_keywords(project_keywords_obj)
        #          rest_client.delete_project_keywords(project_keywords_obj_array)
        #          rest_client.delete_project_keywords([1,2,3])
        #          rest_client.delete_project_keywords(['1','2','3'])
        #          rest_client.delete_project_keywords(1)
        #          rest_client.delete_project_keywords('1')
        def delete_project_keywords(data=nil)
            uri = URI.parse(@uri + "/ProjectKeywords")
            delete(uri,data)
        end
        alias :delete_project_keyword :delete_project_keywords

        ##############################
        #                            #
        # PROJECT KEYWORD CATEGORIES #
        #                            #
        ##############################

        # Retrieve project keyword categories.
        #
        # @param query_obj[RestOptions Object] Specify query parameters string (Optional)
        # @return [Array] Array of ProjectKeywordCategories objects.
        #
        # @example
        #          rest_client.get_project_keyword_categories()
        #          rest_client.get_project_keyword_categories(rest_options_object)
        def get_project_keyword_categories(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/ProjectKeywordCategories")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_project_keyword_category :get_project_keyword_categories

        # Create project keyword categories.
        #
        # @param data [Single ProjectKeywordCategories Object, Array of ProjectKeywordCategories Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after object creation
        # @return [JSON object] HTTP response JSON object. Returns ProjectKeywordCategories objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.create_project_keyword_categories(project_keyword_categories_obj)
        #          rest_client.create_project_keyword_categories(project_keyword_categories_obj,true)
        #          rest_client.create_project_keyword_categories(project_keyword_categories_obj_array)
        #          rest_client.create_project_keyword_categories(project_keyword_categories_obj_array,true)
        def create_project_keyword_categories(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/ProjectKeywordCategories")
            post(uri,data,generate_objects)
        end
        alias :create_project_keyword_category :create_project_keyword_categories

        # Modify project keyword categories.
        #
        # @param data [Single ProjectKeywordCategories Object, Array of ProjectKeywordCategories Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after updating object
        # @return [JSON object] HTTP response JSON object. Returns ProjectKeywordCategories objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.update_project_keyword_categories(project_keyword_categories_obj)
        #          rest_client.update_project_keyword_categories(project_keyword_categories_obj,true)
        #          rest_client.update_project_keyword_categories(project_keyword_categories_obj_array)
        #          rest_client.update_project_keyword_categories(project_keyword_categories_obj_array,true)
        def update_project_keyword_categories(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/ProjectKeywordCategories")
            put(uri,data,generate_objects)
        end
        alias :update_project_keyword_category :update_project_keyword_categories

        # Delete Project Keyword Categories.
        #
        # @param data [Single ProjectKeywordCategories Object, Array of ProjectKeywordCategories Objects, Integer, Integer Array, Numeric String, Numeric String Array] (Required)
        # @return [JSON object] HTTP response JSON object.
        #
        # @example
        #          rest_client.delete_project_keyword_categories(project_keyword_categories_obj)
        #          rest_client.delete_project_keyword_categories(project_keyword_categories_obj_array)
        #          rest_client.delete_project_keyword_categories([1,2,3])
        #          rest_client.delete_project_keyword_categories(['1','2','3'])
        #          rest_client.delete_project_keyword_categories(1)
        #          rest_client.delete_project_keyword_categories('1')
        def delete_project_keyword_categories(data=nil)
            uri = URI.parse(@uri + "/ProjectKeywordCategories")
            delete(uri,data)
        end
        alias :delete_project_keyword_category :delete_project_keyword_categories

        ############
        #          #
        # SEARCHES #
        #          #
        ############

        # Retrieve searches.
        #
        # @param query_obj[RestOptions Object] Specify query parameters string (Optional)
        # @return [Array] Array of Searches objects.
        #
        # @example
        #          rest_client.get_searches()
        #          rest_client.get_searches(rest_options_object)
        def get_searches(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/Searches")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_search :get_searches

        # Create Searches.
        #
        # @param data [Single Searches Object, Array of Searches Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after object creation
        # @return [JSON object] HTTP response JSON object. Returns Searches objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.create_searches(searches_obj)
        #          rest_client.create_searches(searches_obj,true)
        #          rest_client.create_searches(searches_obj_array)
        #          rest_client.create_searches(searches_obj_array,true)
        def create_searches(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/Searches")
            post(uri,data,generate_objects)
        end
        alias :create_search :create_searches

        # Modify Searches.
        #
        # @param data [Single Searches Object, Array of Searches Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after updating object
        # @return [JSON object] HTTP response JSON object. Returns Searches objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.update_searches(searches_obj)
        #          rest_client.update_searches(searches_obj,true)
        #          rest_client.update_searches(searches_obj_array)
        #          rest_client.update_searches(searches_obj_array,true)
        def update_searches(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/Searches")
            put(uri,data,generate_objects)
        end
        alias :update_search :update_searches

        #########
        #       #
        # SIZES #
        #       #
        #########

        # Retrieve sizes.
        #
        # @param query_obj[RestOptions Object] Specify query parameters string (Optional)
        # @return [Array] Array of Sizes objects.
        #
        # @example
        #          rest_client.get_image_sizes()
        #          rest_client.get_image_sizes(rest_options_object)
        def get_image_sizes(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/Sizes")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_image_size :get_image_sizes

        # Create image Sizes.
        #
        # @param data [Single Sizes Object, Array of Sizes Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after object creation
        # @return [JSON object] HTTP response JSON object. Returns ImageSizes objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.create_image_sizes(image_sizes_obj)
        #          rest_client.create_image_sizes(image_sizes_obj,true)
        #          rest_client.create_image_sizes(image_sizes_obj_array)
        #          rest_client.create_image_sizes(image_sizes_obj_array,true)
        def create_image_sizes(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/Sizes")
            post(uri,data,generate_objects)
        end
        alias :create_image_size :create_image_sizes

        # Modify image Sizes.
        #
        # @param data [Single Sizes Object, Array of Sizes Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after updating object
        # @return [JSON object] HTTP response JSON object. Returns ImageSizes objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.update_image_sizes(image_sizes_obj)
        #          rest_client.update_image_sizes(image_sizes_obj,true)
        #          rest_client.update_image_sizes(image_sizes_obj_array)
        #          rest_client.update_image_sizes(image_sizes_obj_array,true)
        def update_image_sizes(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/Sizes")
            put(uri,data,generate_objects)
        end
        alias :update_image_size :update_image_sizes

        # Delete Image Sizes.
        #
        # @param data [Single Sizes Object, Array of Sizes Objects, Integer, Integer Array, Numeric String, Numeric String Array] (Required)
        # @return [JSON object] HTTP response JSON object.
        #
        # @example
        #          rest_client.delete_image_sizes(image_sizes_obj)
        #          rest_client.delete_image_sizes(image_sizes_obj_array)
        #          rest_client.delete_image_sizes([1,2,3])
        #          rest_client.delete_image_sizes(['1','2','3'])
        #          rest_client.delete_image_sizes(1)
        #          rest_client.delete_image_sizes('1')
        def delete_image_sizes(data=nil)
            uri = URI.parse(@uri + "/Sizes")
            delete(uri,data)
        end
        alias :delete_image_size :delete_image_sizes

        #################
        #               #
        # TEXT REWRITES #
        #               #
        #################

        # Retrieve Text Rewrites.
        #
        # @param query_obj[RestOptions Object] Specify query parameters string (Optional)
        # @return [Array] Array of TextRewrites objects.
        #
        # @example
        #          rest_client.get_text_rewrites()
        #          rest_client.get_text_rewrites(rest_options_object)
        def get_text_rewrites(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/TextRewrites")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_text_rewrite :get_text_rewrites

        #########
        #       #
        # USERS #
        #       #
        #########

        # Retrieve Users.
        #
        # @param query_obj[RestOptions Object] Specify query parameters string (Optional)
        # @return [Array] Array of Users objects.
        #
        # @example
        #          rest_client.get_users()
        #          rest_client.get_users(rest_options_object)
        def get_users(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/Users")
            handle_get_request(uri,query_obj,with_nested_resources)
        end
        alias :get_user :get_users

        # Create Users.
        #
        # @param data [Single Users Object, Array of Users Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after object creation
        # @return [JSON object] HTTP response JSON object. Returns ImageSizes objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.create_users(users_obj)
        #          rest_client.create_users(users_obj,true)
        #          rest_client.create_users(users_obj_array)
        #          rest_client.create_users(users_obj_array,true)
        def create_users(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/Users")
            post(uri,data,generate_objects)
        end
        alias :create_user :create_users

        # Update Users.
        #
        # @param data [Single Users Object, Array of Users Objects] (Required)
        # @param generate_objects [Boolean] (Optional)
        #        Caution: Hurts performance -> Only use if performing further edits after object creation
        # @return [JSON object] HTTP response JSON object. Returns ImageSizes objects array if generate_objects flag is set
        #
        # @example
        #          rest_client.update_users(users_obj)
        #          rest_client.update_users(users_obj,true)
        #          rest_client.update_users(users_obj_array)
        #          rest_client.update_users(users_obj_array,true)
        def update_users(data=nil,generate_objects=false)
            uri = URI.parse(@uri + "/Users")
            put(uri,data,generate_objects)
        end
        alias :update_user :update_users

        # Delete Users.
        #
        # @param data [Single Users Object, Array of Users Objects, Integer, Integer Array, Numeric String, Numeric String Array] (Required)
        # @return [JSON object] HTTP response JSON object.
        #
        # @example
        #          rest_client.delete_users(users_obj)
        #          rest_client.delete_users(users_obj_array)
        #          rest_client.delete_users([1,2,3])
        #          rest_client.delete_users(['1','2','3'])
        #          rest_client.delete_users(1)
        #          rest_client.delete_users('1')
        def delete_users(data=nil)
            uri = URI.parse(@uri + "/Users")
            delete(uri,data)
        end
        alias :delete_user :delete_users

        ############################
        #                          #
        # Administrative Functions #
        #                          #
        ############################

        # Tag Files with keywords.
        #
        # @param files [Single Files Object, Array of Files Objects] (Required)
        # @param keywords [Single Keywords Object, Array of Keywords Objects] (Required)
        # @return [JSON object] HTTP response JSON object.
        #
        # @example
        #          rest_client.file_add_keywords(files_object,keywords_object)
        #          rest_client.file_add_keywords(files_objects_array,keywords_objects_array)
        #          rest_client.file_add_keywords(files_object,keywords_objects_array)
        #          rest_client.file_add_keywords(files_objects_array,project_keywords_object)
        def file_add_keywords(files=nil,keywords=nil)
            __file_add_keywords(files,keywords)
        end
        alias :file_add_keyword :file_add_keywords
        alias :files_add_keyword :file_add_keywords
        alias :files_add_keywords :file_add_keywords

        # Tag Projects with keywords.
        #
        # @param projects [Single Projects Object, Array of Projects Objects] (Required)
        # @param proj_keywords [Single ProjectKeywords Object, Array of ProjectKeywords Objects] (Required)
        # @return [JSON object] HTTP response JSON object.
        #
        # @example
        #          rest_client.project_add_keywords(projects_object,project_keywords_object)
        #          rest_client.project_add_keywords(projects_objects_array,project_keywords_objects_array)
        #          rest_client.project_add_keywords(projects_object,project_keywords_objects_array)
        #          rest_client.project_add_keywords(projects_objects_array,project_keywords_object)
        def project_add_keywords(projects=nil,proj_keywords=nil)
            __project_add_keywords(projects,proj_keywords)
        end
        alias :project_add_keyword :project_add_keywords
        alias :projects_add_keyword :project_add_keywords
        alias :projects_add_keywords :project_add_keywords

        # Add data to ANY File field (built-in or custom).
        #
        # @param file [Files Object] (Required)
        # @param field [Fields Object] (Required)
        # @param value [String, Integer, Float] (Required)
        # @return [JSON object] HTTP response JSON object.
        #
        # @example
        #          rest_client.file_add_field_data(files_object,fields_object,'data to be inserted')
        def file_add_field_data(file=nil,field=nil,value=nil)
            __file_add_field_data(file,field,value)
        end

        # Add data to ANY Project field (built-in or custom).
        #
        # @param project [Projects Object] (Required)
        # @param field [Fields Object] (Required)
        # @param value [String, Integer, Float] (Required)
        # @return [JSON object] HTTP response JSON object.
        #
        # @example
        #          rest_client.project_add_field_data(projects_object,fields_object,'data to be inserted')
        def project_add_field_data(project=nil,field=nil,value=nil)
            __project_add_field_data(project,field,value)
        end

        # Move file field data to keywords BY ALBUM for ANY File field (built-in or custom) and tag associated files.
        #
        # @param album [Albums Object, String album name, String id, Integer id] (Required)
        # @param target_keyword_category [KeywordCategories Object, String keyword category name, String id, Integer id] (Required)
        # @param source_field [Fields Object, String field name, String id, Integer id] (Required)
        # @param field_separator [String] (Required)
        # @param batch_size [Integer] (Default => 200)
        # @return [nil] nil.
        #
        # @example
        #          rest_client.move_file_keywords_to_field_by_album(Albums object,KeywordCategories object,Fields object,';',250)
        #          rest_client.move_file_field_data_to_keywords_by_album("myalbum","keyword_category_name","file_field_name",';',250)
        #          rest_client.move_file_field_data_to_keywords_by_album("9","1","7",';',250)
        #          rest_client.move_file_field_data_to_keywords_by_album(9,1,7,';',250)
        def move_file_field_data_to_keywords_by_album(album=nil,
                                                     target_keyword_category=nil,
                                                     source_field=nil,
                                                     field_separator=nil,
                                                     batch_size=200)

            __move_file_field_data_to_keywords_by_album(album,
                                                    target_keyword_category,
                                                    source_field,
                                                    field_separator,
                                                    batch_size)
        end

        # Move file field data to keywords BY CATEGORY for ANY File field (built-in or custom) and tag associated files.
        #
        # @param category [Categories Object, String File category name, String id, Integer id] (Required)
        # @param target_keyword_category [KeywordCategories Object, String keyword category name, String id, Integer id] (Required)
        # @param source_field [Fields Object, String field name, String id, Integer id] (Required)
        # @param field_separator [String] (Required)
        # @param batch_size [Integer] (Default => 200)
        # @return [nil] nil.
        #
        # @example
        #          rest_client.move_file_field_data_to_keywords_by_category(Categories object,KeywordCategories object,Fields object,';',250)
        #          rest_client.move_file_field_data_to_keywords_by_category("Projects","keyword_category_name","file_field_name",';',250)
        #          rest_client.move_file_field_data_to_keywords_by_category("9","1","7",';',250)
        #          rest_client.move_file_field_data_to_keywords_by_category(9,1,7,';',250)
        def move_file_field_data_to_keywords_by_category(category=nil,
                                                        target_keyword_category=nil,
                                                        source_field=nil,
                                                        field_separator=nil,
                                                        batch_size=200)

             __move_file_field_data_to_keywords_by_category(category,
                                                       target_keyword_category,
                                                       source_field,
                                                       field_separator,
                                                       batch_size)

        end

        # Move file field data to keywords BY PROJECT for ANY File field (built-in or custom) and tag associated files.
        #
        # @param project [Projects object, project_name, String id, Integer id] (Required)
        # @param target_keyword_category [KeywordCategories Object, String keyword category name, String id, Integer id] (Required)
        # @param source_field [Fields Object, String field name, String id, Integer id] (Required)
        # @param field_separator [String] (Required)
        # @param batch_size [Integer] (Default => 100)
        # @return [nil] nil.
        #
        # @example
        #          rest_client.move_file_field_data_to_keywords_by_project(Projects object,KeywordCategories object,Fields object,';',250)
        #          rest_client.move_file_field_data_to_keywords_by_project("MyProject","keyword category name","file field name",';',250)
        #          rest_client.move_file_field_data_to_keywords_by_project("9","1","7",';',250)
        #          rest_client.move_file_field_data_to_keywords_by_project(9,1,7,';',250)
        def move_file_field_data_to_keywords_by_project(project=nil,
                                                       target_keyword_category=nil,
                                                       source_field=nil,
                                                       field_separator=nil,
                                                       batch_size=200)

            __move_file_field_data_to_keywords_by_project(project,
                                                     target_keyword_category,
                                                     source_field,
                                                     field_separator,
                                                     batch_size)

        end

        # Move project field data to keywords for ANY Project field (built-in or custom).
        #
        # @param target_project_keyword_category [ProjectKeywordCategories Object, String keyword category name, String id, Integer id] (Required)
        # @param project_field [Fields Object, String field name, String id, Integer id] (Required)
        # @param field_separator [String] (Required)
        # @param batch_size [Integer] (Default => 200)
        # @return [nil] nil.
        #
        # @example
        #          rest_client.move_project_field_data_to_keywords(ProjectKeywordCategories object,Fields object,';',250)
        #          rest_client.move_project_field_data_to_keywords("project keyword category name","project field name",';',250)
        #          rest_client.move_project_field_data_to_keywords("9","17",';',250)
        #          rest_client.move_project_field_data_to_keywords(9,17,';',250)
        def move_project_field_data_to_keywords(target_project_keyword_category=nil,
                                                project_field=nil,
                                                field_separator=nil,
                                                batch_size=200)

             __move_project_field_data_to_keywords(target_project_keyword_category,
                                                   project_field,
                                                   field_separator,
                                                   batch_size)

        end

        # Move project keywords to field (built-in or custom) Excludes Date and On/Off Switch field types.
        #
        # @param source_project_keyword_category [ProjectKeywordCategories Object, Fields object, String id, Integer id] (Required)
        # @param target_project_field [Fields Object, String field name, String id, Integer id] (Required)
        # @param field_separator [String] (Required)
        # @param insert_mode [String] append or overwrite
        # @param batch_size [Integer] (Default => 200)
        # @return [nil] nil.
        #
        # @example
        #          rest_client.move_project_keywords_to_field(ProjectKeywordCategories object,Fields object,';','append',250)
        #          rest_client.move_project_keywords_to_field(ProjectKeywordCategories object,Fields object,';','overwrite',250)
        #          rest_client.move_project_keywords_to_field("project keyword category name","project field name",';','append',250)
        #          rest_client.move_project_keywords_to_field("project keyword category name","project field name",';','overwrite',250)
        #          rest_client.move_project_keywords_to_field("9","1","7",';','append',250)
        #          rest_client.move_project_keywords_to_field("9","1","7",';','overwrite',250)
        #          rest_client.move_project_keywords_to_field(9,1,7,';','append',250)
        #          rest_client.move_project_keywords_to_field(9,1,7,';','overwrite',250)
        def move_project_keywords_to_field(source_project_keyword_category=nil,
                                           target_project_field=nil,
                                           field_separator=nil,
                                           insert_mode=nil,
                                           batch_size=200)

            __move_project_keywords_to_field(source_project_keyword_category,
                                             target_project_field,
                                             field_separator,
                                             insert_mode,
                                             batch_size)

        end

        # Move file keywords to field (built-in or custom) BY ALBUM - Excludes Date and On/Off Switch field types.
        #
        # @param album [Albums object, String album name, String id, Integer id] (Required)
        # @param keyword_category [KeywordCategories Object, String keyword category name (PREFERRED INPUT), String id, Integer id] (Required)
        # @param target_field [Fields Object, String field name, String id, Integer id] (Required)
        # @param field_separator [String] (Required)
        # @param insert_mode [String] append or overwrite
        # @param batch_size [Integer] (Default => 200)
        # @return [nil] nil.
        #
        # @example
        #          rest_client.move_file_keywords_to_field_by_album(Albums object,KeywordCategories object,Fields object,';','append',250)
        #          rest_client.move_file_keywords_to_field_by_album(Albums object,KeywordCategories object,Fields object,';','overwrite',250)
        #          rest_client.move_file_keywords_to_field_by_album("album name","keyword category name","file field name",';','append',250)
        #          rest_client.move_file_keywords_to_field_by_album("album name","keyword category name","file field name",';','overwrite',250)
        #          rest_client.move_file_keywords_to_field_by_album("9","1","7",';','append',250)
        #          rest_client.move_file_keywords_to_field_by_album("9","1","7",';','overwrite',250)
        #          rest_client.move_file_keywords_to_field_by_album(9,1,7,';','append',250)
        #          rest_client.move_file_keywords_to_field_by_album(9,1,7,';','overwrite',250)
        def move_file_keywords_to_field_by_album(album,
                                                 keyword_category,
                                                 target_field,
                                                 field_separator,
                                                 insert_mode=nil,
                                                 batch_size=200)

            __move_file_keywords_to_field_by_album(album,
                                                   keyword_category,
                                                   target_field,
                                                   field_separator,
                                                   insert_mode,
                                                   batch_size)

        end

        # Move file keywords to field (built-in or custom) BY PROJECT - Excludes Date and On/Off Switch field types.
        #
        # @param project [Projects object, String project name, String id, Integer id] (Required)]
        # @param keyword_category [KeywordCategories Object, String keyword category name (PREFERRED INPUT), String id, Integer id] (Required)
        # @param target_field [Fields Object, String field name, String id, Integer id] (Required)
        # @param field_separator [String] (Required)
        # @param insert_mode [String] append or overwrite
        # @param batch_size [Integer] (Default => 200)
        # @return [nil] nil.
        #
        # @example
        #          rest_client.move_file_keywords_to_field_by_project(Projects object,KeywordCategories object,Fields object,';','append',250)
        #          rest_client.move_file_keywords_to_field_by_project(Projects object,KeywordCategories object,Fields object,';','overwrite',250)
        #          rest_client.move_file_keywords_to_field_by_project("project name","keyword category name","file field name",';','append',250)
        #          rest_client.move_file_keywords_to_field_by_project("project name","keyword category name","file field name",';','overwrite',250)
        #          rest_client.move_file_keywords_to_field_by_project("9","1","7",';','append',250)
        #          rest_client.move_file_keywords_to_field_by_project("9","1","7",';','overwrite',250)
        #          rest_client.move_file_keywords_to_field_by_project(9,1,7,';','append',250)
        #          rest_client.move_file_keywords_to_field_by_project(9,1,7,';','overwrite',250)
        def move_file_keywords_to_field_by_project(project,
                                                   keyword_category,
                                                   target_field,
                                                   field_separator,
                                                   insert_mode=nil,
                                                   batch_size=200)

            __move_file_keywords_to_field_by_project(project,
                                                     keyword_category,
                                                     target_field,
                                                     field_separator,
                                                     insert_mode,
                                                     batch_size)

        end

        # Move file keywords to field (built-in or custom) BY CATEGORY - Excludes Date and On/Off Switch field types.
        #
        # @param category [Categories object, String category name, String id, Integer id] (Required)]
        # @param keyword_category [KeywordCategories Object, String keyword category name, String id, Integer id] (Required)
        # @param target_field [Fields Object, String field name, String id, Integer id] (Required)
        # @param field_separator [String] (Required)
        # @param insert_mode [String] append or overwrite
        # @param batch_size [Integer] (Default => 200)
        # @return [nil] nil.
        #
        # @example
        #          rest_client.move_file_keywords_to_field_by_category(Categories object,KeywordCategories object,Fields object,';','append',250)
        #          rest_client.move_file_keywords_to_field_by_category(Categories object,ProjectKeywordCategories object,Fields object,';','overwrite',250)
        #          rest_client.move_file_keywords_to_field_by_category("category name","keyword category name","file field name",';','append',250)
        #          rest_client.move_file_keywords_to_field_by_category("category name","keyword category name","file field name",';','overwrite',250)
        #          rest_client.move_file_keywords_to_field_by_category("9","1","7",';','append',250)
        #          rest_client.move_file_keywords_to_field_by_category("9","1","7",';','overwrite',250)
        #          rest_client.move_file_keywords_to_field_by_category(9,1,7,';','append',250)
        #          rest_client.move_file_keywords_to_field_by_category(9,1,7,';','overwrite',250)
        def move_file_keywords_to_field_by_category(category,
                                                    keyword_category,
                                                    target_field,
                                                    field_separator,
                                                    insert_mode=nil,
                                                    batch_size=200)

            __move_file_keywords_to_field_by_category(category,
                                                      keyword_category,
                                                      target_field,
                                                      field_separator,
                                                      insert_mode,
                                                      batch_size)

        end

        # Assign hero images to projects.
        #
        # @param options [Hash -> attribute,overwrite,order,value,batch_size] (optional)
        # @return [nil] nil.
        #
        # @example
        #          options = {'attribute' => 'rank, 'order' => 'asc', overwrite' => true, 'value' => 1, 'batch_size' => 250}
        #          rest_client.assign_hero_images(options)
        def assign_hero_images(options={})
            __assign_hero_images(options)
        end

    end

end

