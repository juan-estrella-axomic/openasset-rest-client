require_relative 'Version/version'
require_relative 'Authenticator'
require_relative 'RestOptions'
require_relative 'MyLogger'
require_relative 'Encoder'
require_relative 'Error'

require 'net/http'


#Includes all the nouns in one shot
Dir[File.join(File.dirname(__FILE__),'Nouns','*.rb')].each { |file| require_relative file }

module OpenAsset

    class RestClient

        # Provides a globally shared singleton logger 
        include Logging
        include Encoder
        
        RESTRICTED_LIST_FIELD_TYPES   = %w[ suggestion fixedSuggestion option ]
        NORMAL_FIELD_TYPES            = %w[ singleLine multiLine ]
        ALLOWED_BOOLEAN_FIELD_OPTIONS = %w[ enable disable yes no set unset check uncheck tick untick on off true false 1 0]

        # @!parse attr_reader :session, :uri
        attr_reader :session, :uri
        
        # @!parse attr_accessor :verbose
        attr_accessor :verbose, :char_encoding

        # Create new instance of the OpenAsset rest client
        #
        # @param client_url [string] Cloud client url
        # @return [RestClient object]
        #
        # @example 
        #         rest_client = OpenAsset::RestClient.new('se1.openasset.com')
        def initialize(client_url,un='',pw='')

            @authenticator = Authenticator.get_instance(client_url,un,pw)
            @session       = @authenticator.get_session
            @uri           = @authenticator.uri
            @verbose       = false
            @incoming_encoding = 'utf-8' #Assume utf-8 unless web server specifies differently
            @outgoing_encoding = 'utf-8'

        end

        private
        # @!visibility private
        def process_field_to_keyword_move_args(scope,
                                               container,
                                               target_keyword_category,
                                               source_field,
                                               field_separator,
                                               batch_size,
                                               allow_mutiple_results=false)
                                               
            op = RestOptions.new

            container_found             = nil
            keyword_category_found      = nil
            source_field_found          = nil

            if scope.downcase == 'albums'

                if container.is_a?(Albums) # Object
                    op.add_option('id',container.id)
                    container_found = get_albums(op).first

                    unless container_found
                        msg = "Album id #{album.id} not found in OpenAsset. Aborting."
                        logger.error(msg)
                        abort
                    end

                elsif (container.is_a?(String) && container.to_i > 0) || container.is_a?(Integer) # Album id
                    op.add_option('id',container)
                    container_found = get_albums(op).first

                    unless container_found
                        msg = "Album id #{album.inspect} not found in OpenAsset. Aborting"
                        logger.error(msg)
                        abort
                    end

                elsif container.is_a?(String) # Album name
                    op.add_option('name',container)
                    op.add_option('textMatching','exact')
                    container_found = get_albums(op)

                    if container_found.length > 1
                        msg = "Multiple #{scope} found named #{container.inspect}. Specify an id instead."
                        logger.error(msg)
                        abort
                    end

                    if container_found.empty?
                        msg = "Album named #{container.inspect} not found in OpenAsset. Aborting"
                        logger.error(msg)
                        abort
                    end
                    container_found = container_found.first
                else
                    msg = "Argument Error: Expected a Albums object, Album name, or Album id for the first argument in #{__callee__}" +
                          "\n    Intead got #{container.inspect}"
                    logger.error(msg)
                    abort
                end

                unless container_found && !container_found.files.empty?
                    msg = "Album #{container_found.name.inspect} is empty"
                    logger.warn(msg.yellow)
                    return
                end

            elsif scope.downcase == 'projects'

                if container.is_a?(Projects) # Object
                    op.add_option('id',container.id)
                    container_found = get_projects(op).first

                    unless container_found
                        msg = "Project id #{container.id} not found in OpenAsset. Aborting."
                        logger.error(msg)
                        abort
                    end

                elsif (container.is_a?(String) && container.to_i > 0) || container.is_a?(Integer) # Album id
                    op.add_option('id',container)
                    container_found = get_projects(op).first

                    unless container_found
                        msg = "Project id #{container} not found in OpenAsset. Aborting."
                        logger.error(msg)
                        abort
                    end
                    
                elsif container.is_a?(String) # project name
                    op.add_option('name',container)
                    op.add_option('textMatching','exact')
                    container_found = get_projects(op)

                    if container_found.length > 1
                        msg = "Multiple #{scope} found named #{container.inspect}. Specify an id instead."
                        logger.error(msg)
                        abort
                    end

                    if container_found.empty?
                        msg = "Project named #{container.inspect} not found in OpenAsset. Aborting."
                        logger.error(msg)
                        abort
                    end

                    container_found = container_found.first
                else
                    msg = "Argument Error: Expected a Projects object, Project name, or Project id for the first argument in #{__callee__}" +
                          "\n    Intead got #{container.inspect}"
                    logger.error(msg)
                    abort
                end

            elsif scope.downcase == 'categories'

                if container.is_a?(Categories) # Object
                    op.add_option('id',container.id)
                    container_found = get_categories(op).first

                    unless container_found
                        msg = "Category id #{container.id} not found in OpenAsset. Aborting."
                        logger.error(msg)
                        abort
                    end

                elsif (container.is_a?(String) && container.to_i > 0) || container.is_a?(Integer) # Category id
                    op.add_option('id',container)
                    container_found = get_categories(op).first

                    unless container_found
                        msg = "Category id #{container.inspect} not found in OpenAsset. Aborting."
                        logger.error(msg)
                        abort
                    end

                elsif container.is_a?(String) # Category name

                    op.add_option('name',container)
                    op.add_option('textMatching','exact')
                    container_found = get_categories(op)

                    if container_found.length > 1
                        msg = "Multiple #{scope} found named #{container.inspect}. Specify an id instead."
                        logger.error(msg)
                        abort
                    end

                    if container_found.empty?
                        msg = "Category named #{container.inspect} not found in OpenAsset. Aborting."
                        logger.error(msg)
                        abort
                    end
                    
                    container_found = container_found.first

                else
                    msg = "Argument Error: Expected a Categories object, Category name, or Category id for the first argument in #{__callee__}" +
                    "\n    Intead got #{container.inspect}"
                    logger.error(msg)
                    abort
                end

            end
                
            op.clear

            if target_keyword_category.is_a?(KeywordCategories) # Object

                op.add_option('id',target_keyword_category.id)
                keyword_category_found = get_keyword_categories(op).first

                unless keyword_category_found
                    msg = "FILE Keyword Category id \"#{target_keyword_category.id}\" not found in OpenAsset. Aborting."
                    logger.error(msg)
                    abort
                end

            elsif (target_keyword_category.is_a?(String) && 
                   target_keyword_category.to_i > 0) || 
                   target_keyword_category.is_a?(Integer) # Keyword category id

                op.add_option('id',target_keyword_category)
                keyword_category_found = get_keyword_categories(op).first

                unless keyword_category_found
                    msg = "FILE Keyword Category id \"#{target_keyword_category}\" not found in OpenAsset. Aborting."
                    logger.error(msg)
                    abort
                end

            elsif target_keyword_category.is_a?(String) # Keyword category name

                op.add_option('name',target_keyword_category)
                op.add_option('textMatching','exact')

                results = get_keyword_categories(op)    
                
                if results.empty?
                    msg = "FILE Keyword Category \"#{target_keyword_category}\" not found in OpenAsset. Aborting."
                    logger.error(msg)
                    abort
                end

                if results.length > 1 && allow_mutiple_results == false
                    msg = "Multiple File keyword categories found with name => #{target_keyword_category.inspect}. Specify an id instead."
                    logger.error(msg)
                    abort
                elsif results.length > 1 && allow_mutiple_results == true
                    keyword_category_found = results
                else
                    keyword_category_found = results.first
                end
            
            else
                msg = "Argument Error: Expected \n    1.) File keyword categories object\n    2.) File keyword " +
                      "category name\n    3.) File keyword category id\nfor the second argument in #{__callee__}." +
                      "\n    Intead got #{target_keyword_category.inspect}"
                logger.error(msg)
                abort
            end

            op.clear

            if source_field.is_a?(Fields) # Object

                op.add_option('id',source_field.id)
                source_field_found = get_fields(op).first

                unless source_field_found
                    msg = "Field id #{source_field.id} not found in OpenAsset. Aborting."
                    logger.error(msg)
                    abort
                end

            elsif (source_field.is_a?(String) && source_field.to_i > 0) || source_field.is_a?(Integer) # Field id

                op.add_option('id',source_field)
                source_field_found = get_fields(op).first

                unless source_field_found
                    msg = "Field id #{source_field} not found in OpenAsset. Aborting."
                    logger.error(msg)
                    abort
                end

            elsif source_field.is_a?(String) # Field name

                op.add_option('name',source_field)
                op.add_option('textMatching','exact')
                results = get_fields(op)
                
                if results.length > 1
                    msg = "Multiple Fields found named #{source_field.inspect}. Specify an id instead."
                    logger.error(msg)
                    abort
                end

                if results.empty?
                    msg = "Field named #{source_field.inspect} not found in OpenAsset. Aborting."
                    logger.error(msg)
                    abort
                end

                source_field_found = results.first
            else
                msg = "Argument Error: Expected a Fields object, File Field name, or File Field id for the third argument in #{__callee__}" +
                      "\n    Intead got #{source_field.inspect}"
                logger.error(msg)
                abort
            end

            unless source_field_found.field_type == 'image'
                msg = "Field #{source_field_found.name.inspect} with id #{source_field_found.id.inspect} is not an image field. Aborting."
                logger.error(msg)
                abort
            end

            op.clear

            unless field_separator.is_a?(String) && !field_separator.nil?
                msg = "Argument Error: Expected a string value for the fourth argument \"field_separator\"." +
                      "\n    Instead got #{field_separator.inspect}."
                logger.error(msg)
                abort
            end

            unless batch_size.to_i > 0
                msg = "Argument Error: Expected a non zero numeric value for the fifth argument \"batch size\" in #{__callee__}." +
                      "\n    Instead got #{batch_size.inspect}."
                logger.error(msg)
                abort
            end

            args = Struct.new(:container, :source_field, :target_keyword_category)

            return args.new(container_found, source_field_found, keyword_category_found)

        end

        # @!visibility private
        def process_errors(data=nil,res=nil,resource=nil,operation='')

            return unless data && res && resource

            json_obj_collection = Array.new
            errors              = Array.new
            json_body           = Array.new
            
            name = (resource == 'Files') ? '@filename' : '@name'

            begin
                jsonBody = JSON.parse(res.body) if res.body
            rescue JSON::ParserError => err
                logger.error("JSON Parser Error: #{err.message}")
            end

            if !jsonBody.is_a?(Array)
                jsonBody = [jsonBody]
            end
            
            data = [data] unless data.is_a?(Array)

            if res.body
                jsonBody.each_with_index do |obj,index|
                    if obj.is_a?(Hash) && obj.has_key?("error_message")
                        err                     = Hash.new
                        err['id']               = data[index].id  unless data[index].nil?
                        err['resource_name']    = data[index].instance_variable_get(name)  unless data[index].nil?
                        err['resource_type']    = resource  # Determined by api endpoint
                        err['http_status_code'] = obj['http_status_code']
                        err['error_message']    = obj['error_message']
        
                        errors << err
                        #json_obj_collection << err
                    else
                        json_obj_collection << obj
                    end
                end
            end

            unless errors.empty?
                errors.each do |e|
                    n = e["resource_name"]
                    r = e["resource_type"]
                    i = e["id"]
                    m = e["error_message"]
                    c = e["http_status_code"]
                    logger.error("#{operation} failed for #{r.inspect} object: #{n}")
                    logger.error("#{r.chop} id: #{i}")   unless i.nil?
                    logger.error("Message: #{m}")
                    logger.error("HTTP Status Code: #{c}")
                end
            end

            json_obj_collection 
        end
        
        # @!visibility private
        def generate_objects_from_json_response_body(json,resource_type)    
            
            unless json.empty?

                # Dynamically infer the the class needed to create objects by using the request_uri REST endpoint
                # returns the Class constant so we can dynamically set it below
                inferred_class = Object.const_get(resource_type)
              
                # Create array of JSON Converted to objects => this can include Nouns AND Error objects
                objects_array = json.map do |item|
                    obj = nil
                    if item.has_key?("error_message")
                        obj = Error.new(item["id"],
                                        item["resource_name"],
                                        item["resource_type"],
                                        item["http_status_code"],
                                        item["error_message"])
                        
                    else
                        obj = inferred_class.new(item)
                    end
                    obj
                end
                # return array of rest noun and/or error objects
                return objects_array
            else
                # return empty body 
                 return json
            end
        end 

        # @!visibility private 
        def get_count(object=nil,rest_option_obj=nil) #can be used to get count of other resources in the future
            resource = (object) ? object.class.to_s : object
            query    = (rest_option_obj) ? rest_option_obj.get_options : ''

            unless Validator::NOUNS.include?(resource)
                msg = "Argument Error: Expected Nouns Object for first argument in #{__callee__}." +
                      "\n    Instead got => #{object.inspect}"
                logger.error(msg)
                abort
            end

            unless rest_option_obj.is_a?(RestOptions) || rest_option_obj == nil
                msg = "Argument Error: Expected RestOptions Object or no argument for second argument in #{__callee__}." + 
                      "\n    Instead got => #{rest_option_obj.inspect}"
                logger.error(msg)
                abort
            end

            uri = URI.parse(@uri + '/' + resource + query)                                   

            response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
                request = Net::HTTP::Head.new(uri.request_uri)
                if @session
                    request.add_field('X-SessionKey',@session)
                else
                    @session = @authenticator.get_session
                    request.add_field('X-SessionKey',@session) 
                end
                http.request(request)
            end

            unless @session == response['X-SessionKey']
                @session = response['X-SessionKey']
            end

            Validator.process_http_response(response,@verbose,resource,'HEAD')

            return unless response.kind_of?(Net::HTTPSuccess)

            response['X-Full-Results-Count'].to_i
        end

        # @!visibility private
        def move_keywords_to_fields(objects,keywords,field,field_separator,mode)
            
            existing_field_lookup_strings = nil
            object_type = objects.first.class.to_s.chop # Projects => Project | Files => File

            # Allows dynamic access to nested keywords for both files and projects
            keyword_accessor = (objects.first.is_a?(Projects) ? '@project_' : '@') + 'keywords'

            # Allows access to project or file names attributes dynamically
            object_name = (objects.first.is_a?(Projects) ? '@name' : '@filename')

            # Check the source_field field type
            built_in = (field.built_in == '1') ? true : false

            # Retrieve existing field lookup strings if the field is a restricted field type
            if RESTRICTED_LIST_FIELD_TYPES.include?(field.field_display_type)
                op = RestOptions.new
                op.add_option('limit','0')
                existing_field_lookup_strings = get_field_lookup_strings(field,op)
            end
            
            objects.each do |object|

                next if object.instance_variable_get("#{keyword_accessor}").empty?
        
                nested_kwd_ids = object.instance_variable_get("#{keyword_accessor}").map { |kwd| kwd.id.to_s }
        
                # Retrieve the actual keyword objects associated with the nested ids
                keyword_data = keywords.find_all do |k_obj| 

                    nested_kwd_ids.include?(k_obj.id.to_s) 
                
                end.sort do | k1, k2 | 
                    
                    k1.name.downcase <=> k2.name.downcase
                
                end
        
                field_string = keyword_data.map(&:name).join(field_separator)
                
                if built_in

                    if mode == 'append'
                        
                        field_name = field.name.downcase.gsub(' ','_')
                        #puts "Field name: #{field_name}"
                        data = file.instance_variable_get("#{field_name}")

                        if data.nil? || data.to_s.strip == ''
                            data = field_string
                        else
                            data = data.to_s.strip + field_separator + field_string
                        end

                        object.instance_variable_set("@#{field_name}",data)

                        msg = "Appending #{data.inspect} into #{field.name.inspect} field" +
                              " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."

                        logger.info(msg.green)

                    elsif mode == 'overwrite'

                        field_name = field.name.downcase.gsub(' ','_')
                        #puts "Field name: #{field_name}"
                        data = field_string

                        object.instance_variable_set("@#{field_name}",data)

                        msg = "Inserting #{data.inspect} into #{field.name.inspect} field" +
                              " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."
                        
                        logger.info(msg.green)

                    end
                        
                else # Custom field

                    # Check if there's already a value in the field
                    index = object.fields.find_index { |f_obj| f_obj.id.to_s == field.id.to_s }        
            
                    if index # There's data in the field
                        
                        if mode == 'append'
            
                            if NORMAL_FIELD_TYPES.include?(field.field_display_type)
            
                                object.fields[index].values = 
                                    [object.fields[index].values.first + field_separator + field_string]
            
                                msg = "Appending #{field_string.inspect} into #{field.name.inspect} field" +
                                      " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."

                                logger.info(msg.green)
                            
                            elsif RESTRICTED_LIST_FIELD_TYPES.include?(field.field_display_type)
            
                                keyword_data.each do |fk|

                                    fls_found = existing_field_lookup_strings.find { |fls| fls.value.downcase == fk.name.downcase }
                                    
                                    # Create the field lookup string if not found and add to existing
                                    unless fls_found
                                        data = {:value => fk.name}
                                        fls_found = create_field_lookup_strings(field,data,true).first
                                        existing_field_lookup_strings.push(fls_found)
                                    end
            
                                    #file_add_field_data(file,field,fk.name.to_s) # Easy but SLOW
            
                                    msg = "Inserting #{fk.name.inspect} into #{field.name.inspect} field" +
                                          " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."

                                    logger.info(msg.green)
            
                                end

                                # Assign the value to the field
                                object.fields[index].values = [keyword_data.first.name]        unless keyword_data.empty?
                            
                            else
            
                                msg = "#{object_type} keyword move operation not allowed to field display type " +
                                      "#{field.field_display_type.inspect}."
                                logger.error(msg)
                                abort
            
                            end
            
                        elsif  mode == 'overwrite'
            
                            if NORMAL_FIELD_TYPES.include?(field.field_display_type)
            
                                object.fields[index].values = [field_string]
            
                                msg "Inserting #{field_string.inspect} into #{field.name.inspect} field" +
                                    " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."

                                logger.info(msg.green)
                            
                            elsif RESTRICTED_LIST_FIELD_TYPES.include?(field.field_display_type)
            
                                keyword_data.each do |fk|

                                    fls_found = existing_field_lookup_strings.find { |fls| fls.value.downcase == fk.name.downcase }
                                    
                                    # Create the field lookup string if not found and add to existing
                                    unless fls_found
                                        data = {:value => fk.name}
                                        fls_found = create_field_lookup_strings(field,data,true).first
                                        existing_field_lookup_strings.push(fls_found)
                                    end
    
                                    # Assign the value to the field
                                    # object.fields[index].values = [fls_found.value]
                                    
                                    #file_add_field_data(file,field,fk.name.to_s) # Easy but SLOW
            
                                    msg = "Inserting #{fk.name.inspect} into #{field.name.inspect} field" +
                                          " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."

                                    logger.info(msg.green)
            
                                end
                        
                                object.fields[index].values = [keyword_data.first.name]     unless keyword_data.empty?
                            
                            else
            
                                msg = "#{object_type} keyword move operation not allowed to field display type " +
                                      "#{field.field_display_type.inspect}."
                                logger.error(msg)
                                abort
            
                            end
            
                        end
            
                    else # No data in the field
            
                        if NORMAL_FIELD_TYPES.include?(field.field_display_type)
            
                            object.fields << NestedFieldItems.new(field.id.to_s, [field_string])
            
                            msg = "Inserting #{field_string.inspect} into #{field.name.inspect} field" +
                                  " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."

                            logger.info(msg.green)
            
                        elsif RESTRICTED_LIST_FIELD_TYPES.include?(field.field_display_type)
                            
                            keyword_data.each do |fk|                

                                fls_found = existing_field_lookup_strings.find { |fls| fls.value.downcase == fk.name.downcase }

                                # Create the field lookup string if not found and add to existing
                                unless fls_found
                                    data = {:value => fk.name}
                                    fls_found = create_field_lookup_strings(field,data,true).first
                                    existing_field_lookup_strings.push(fls_found)
                                end
                                
                                #file_add_field_data(file,field,fk.name.to_s) # SLOWWWW
            
                                msg = "Inserting #{fk.name.inspect} into #{field.name.inspect} field" +
                                      " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."

                                logger.info(msg.green)
            
                            end
                            
                            # Insert the value to the field if there is one
                            object.fields << NestedFieldItems.new(field.id,[keyword_data.first.name]) unless keyword_data.empty?
                            
                        else
            
                            msg = "#{object_type} keyword move operation not allowed to field display type " +
                                  "#{field.field_display_type.inspect}."
                            logger.error(msg)
                            abort
            
                        end
            
                    end
            
                end

            end
        
            return objects
        end

        # @!visibility private
        def run_smart_update(payload,total_objects_updated)

            scope    = payload.first.class.to_s.downcase
            res      = nil
            attempts = 0
            results_count = 0

            # Perform the update => 3 tries MAX with 5,10,15 second waits between retries
            loop do

                attempts += 1

                #check if the server is responding (This is a HEAD request)
                server_test_passed = get_count(Categories.new)

                # This code executes if the web server hangs or takes too long 
                # to respond after the first update is performed => Possible cause can be too large a batch size
                if attempts == 4
                    Validator.process_http_response(res,@verbose,scope.capitalize,'HEAD')
                    msg = "Max Number of attempts (3) reached!\nThe web server may have taken too long to respond." +
                          " Try adjusting the batch size."
                    logger.error(msg)
                    abort
                end

                if server_test_passed
                    
                    if scope == 'files'
                        res = update_files(payload,false)
                    elsif scope == 'projects'
                        res = update_projects(payload,false)
                    else
                        msg = "Invalid update scope. Expected Files or Projects in payload. Instead got => #{scope}"
                        logger.error(msg)
                        abort
                    end
                        
                    if res.kind_of? Net::HTTPSuccess
                        results_count = res['X-Full-Results-Count'].to_i
                        total_objects_updated = results_count + total_objects_updated
                        msg = ""
                        msg += "Successfully " if total_objects_updated > 0
                        msg += "Updated #{total_objects_updated.inspect} #{scope}."
                        logger.info(msg)
                        break
                    else
                        Validator.process_http_response(res,@verbose,scope.capitalize,'PUT')
                        abort
                    end
                else
                    time_lapse = 5 * attempts
                    time_lapse.times do |num|
                        print "\rWaiting for server to respond" + ("." * (num + 1))
                        sleep(1)
                    end
                end
            end

            return results_count
            
        end

        # @!visibility private
        def wait_and_try_again
            logger.warn("Initial Connection failed. Retrying in 15 seconds.")
            15.times do |num|
                printf("\rRetrying in %-2.0d",(15-num)) 
                sleep(1)
            end
            printf("\rRetrying NOW        \n")
            logger.warn("Re-attempting request. Please wait.")
        end

        # @!visibility private
        def get(uri,options_obj,with_nested_resources=false)
            resource = uri.to_s.split('/').last
            options = options_obj || RestOptions.new
            json_body = []

            if with_nested_resources
            # Ensures File resource query returns all nested resources
                case resource 
                when 'Files'
                    options.add_option('sizes','all')
                    options.add_option('keywords','all')
                    options.add_option('fields','all')
                when 'Albums'
                    options.add_option('files','all')
                    options.add_option('groups','all')
                    options.add_option('users','all')
                when 'Projects'
                    options.add_option('projectKeywords','all')
                    options.add_option('fields','all')
                    options.add_option('albums','all')
                when 'Fields'
                    options.add_option('fieldLookupStrings','all')
                when 'Searches'
                    options.add_option('groups','all')
                    options.add_option('users','all')
                else
                    
                end

            end
            
            begin
                attempts ||= 1
                response = Net::HTTP.start(uri.host, uri.port, :read_timeout => 300, :use_ssl => uri.scheme == 'https') do |http|
                    
                    #Account for 2048 character limit with GET requests
                    options_str_len = options.get_options.length
                    if options_str_len > 2048
                        
                        request = Net::HTTP::Post.new(uri.request_uri)
                        request.add_field('X-Http-Method-Override','GET')

                        post_parameters = {}

                        # Remove beginning ? mark from query
                        key_value_pairs = options.get_options.sub(/^\?/,'')

                        # Break down the string and extract key value arguments for the post parameters
                        key_value_pairs.split(/&/).map do |key_val| 
                            #puts key_val
                            key_val.split(/=/) 

                        end.each do |pair| 
                            
                            key   = pair[0].to_sym
                            value = nil

                            begin
                                value = URI.decode(pair[1])
                            rescue Exception => e
                                require 'pp'
                                pp e
                                logger.error(e.message)
                                logger.error("Bad query parameter => #{key.inspect}=#{value.inspect}")
                                return
                            end

                            # Insert data into post parameters hash 
                            if post_parameters.has_key?(key) # then update it otherwise perform new insert
                                # Check if value for corresponding key is an array -> ex. ?id=[1,2,3] instead of ?id=1,2,3
                                existing_data = post_parameters[key]
                                match         = existing_data =~ /^(\[[\w\s,]+\])$/  

                                if match
                                    begin
                                        arr = JSON.parse(existing_data) # Convert array in string to an actual array
                                        arr.push(value)                 # Insert the URI.decoded value
                                        value = arr.join(',')           # Convert the Array back to a string
                                        post_parameters[key] = value    # Add it to the post parameters HASH
                                    rescue Exception => e
                                        logger.error(e.message)
                                        logger.error("Value causing the error => #{existing_data.inspect}")
                                        abort
                                    end
                                else
                                    post_parameters[key] = existing_data + ',' + value  # For non array list format => ?id=1,2,3
                                end
                                
                            else
                                post_parameters[key] = value # For regular key value format => ?name=joe
                            end
                                    
                        end

                        request.set_form_data(post_parameters)
                    else
                        request = Net::HTTP::Get.new(uri.request_uri + options.get_options) # Create regular GET request
                    end

                    if @session
                        request.add_field('X-SessionKey',@session)
                    else
                        @session = @authenticator.get_session
                        request.add_field('X-SessionKey',@session) 
                    end
            
                    http.request(request) 
                end
            rescue Exception => e
                if attempts < 3
                    wait_and_try_again()
                    attempts += 1
                    retry                
                end
                logger.error("Connection failed. The server is not responding. - #{e}")
                exit(-1)
            end

            unless @session == response['X-SessionKey'] # Upate session if needed
                @session = response['X-SessionKey']
            end

            content_type = response['content-type'] # Identify character encoding

            unless content_type.nil? || content_type.eql?('')
                @incoming_encoding = content_type.split(/=/).last # application/json;charset=windows-1252 => windows-1252
            end

            Validator.process_http_response(response,@verbose,resource,'GET')

            return unless response.kind_of?(Net::HTTPSuccess)

            response.body.encode!(@outgoing_encoding, @incoming_encoding, invalid: :replace, undef: :replace, replace: '?') # Encode returned data into utf-8
            
            begin
                json_body = JSON.parse(response.body)
            rescue JSON::ParserError => e
                logger.error("Error parsing JSON: #{e.message}")
                return []
            end
            return generate_objects_from_json_response_body(json_body, resource)
        end

        # @!visibility private
        def post(uri,data,generate_objects=false)

            data = [data] unless data.is_a?(Array)
            resource = ''
            name     = ''

            if uri.to_s.split('/').last.to_i == 0 #its a non numeric string meaning its a resource endpoint
                resource = uri.to_s.split('/').last
            else
                resource = uri.to_s.split('/')[-2] #the request is using a REST shortcut so we need to grab 
            end                                       #second to last string of the url as the endpoint

            name = (resource == 'Files') ? '@filename' : '@name'

            json_body = Validator.validate_and_process_request_data(data)

            unless json_body
                msg = "No data in json_body in POST request."
                logger.error(msg)
                return false
            end

            begin
                attempts ||= 1
                response = Net::HTTP.start(uri.host, uri.port, :read_timeout => 300, :use_ssl => uri.scheme == 'https') do |http|
                    request = Net::HTTP::Post.new(uri.request_uri)
                    request["content-type"] = "application/json;charset=" + @outgoing_encoding

                    if @session
                        request.add_field('X-SessionKey',@session)
                    else
                        @session = @authenticator.get_session
                        request.add_field('X-SessionKey',@session)
                    end

                    # Logic found in Encoder.rb
                    request.body = encode_json_to_utf8(json_body,@outgoing_encoding,@incoming_encoding)
                    
                    http.request(request)
                end
            rescue Exception => e
                if attempts < 3
                    wait_and_try_again()
                    attempts += 1
                    retry                
                end
                logger.error("Connection failed. The server is not responding. - #{e}")
                exit(-1)
            end

            unless @session == response['X-SessionKey']
                @session = response['X-SessionKey']
            end
            
            
            response = Validator.process_http_response(response,@verbose,resource,'POST')
           
            # Check each objects for errors during update
            res = process_errors(data,response,resource,'Create')

            if generate_objects == true

                return generate_objects_from_json_response_body(res,resource)

            else
                # Raw JSON object
                return response
            end
        end

        # @!visibility private
        def put(uri,data,generate_objects=false)

            resource = uri.to_s.split('/').last
            
            json_body = Validator.validate_and_process_request_data(data)
                 
            unless json_body
                msg = "No data in json_body in PUT request."
                logger.error(msg)
                return false
            end

            begin
                attempts ||= 1
                response = Net::HTTP.start(uri.host, uri.port, :read_timeout => 300, :use_ssl => uri.scheme == 'https') do |http|
                    request = Net::HTTP::Put.new(uri.request_uri)
                    request["content-type"] = "application/json;charset=" + @outgoing_encoding

                    if @session
                        request.add_field('X-SessionKey',@session)
                    else
                        @session = @authenticator.get_session
                        request.add_field('X-SessionKey',@session)
                    end
                    
                    # Logic found in Encoder.rb
                    request.body = encode_json_to_utf8(json_body,@outgoing_encoding,@incoming_encoding)

                    http.request(request)
                end
            rescue Exception => e 
                if attempts < 3
                    wait_and_try_again()
                    attempts += 1
                    retry                
                end
                logger.error("Connection failed. The server is not responding. - #{e}")
                exit(-1)
            end

            unless @session == response['X-SessionKey']
                @session = response['X-SessionKey']
            end
            
            response = Validator.process_http_response(response,@verbose,resource,'PUT')

            # Check each object for error during update
            res = process_errors(data,response,resource,'Update')

            if generate_objects == true

                return generate_objects_from_json_response_body(res,resource)

            else  # Raw JSON object
            
                return response

            end    
        end

        # @!visibility private
        def delete(uri,data)

            resource  = uri.to_s.split('/').last
            
            json_body = Validator.validate_and_process_delete_body(data)

            unless json_body
                msg = "No data in json_body being sent for DELETE request."
                logger.error(msg)
                return false
            end

            begin
                attempts ||= 1
                response = Net::HTTP.start(uri.host, uri.port, :read_timeout => 300, :use_ssl => uri.scheme == 'https') do |http|
                    request = Net::HTTP::Delete.new(uri.request_uri) #e.g. when called in keywords => /keywords/id
                    request["content-type"] = "application/json;charset=" + @outgoing_encoding

                    if @session
                        request.add_field('X-SessionKey',@session)
                    else
                        @session = @authenticator.get_session
                        request.add_field('X-SessionKey',@session)
                    end

                    # Logic found in Encoder.rb
                    request.body = encode_json_to_utf8(json_body,@outgoing_encoding,@incoming_encoding)
                
                    http.request(request)
                end
            rescue Exception => e 
                if attempts < 3
                    wait_and_try_again()
                    attempts += 1
                    retry                
                end
                logger.error("Connection failed. The server is not responding. - #{e}")
                exit(-1)
            end

            unless @session == response['X-SessionKey']
                @session = response['X-SessionKey']
            end        

            response = Validator.process_http_response(response,@verbose,resource,'DELETE')

            res = process_errors(data,response,resource,'Delete')

            return res   # Success should always return an empty array. Any content means there was an error,
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
            get(uri,query_obj,with_nested_resources)
        end

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
            get(uri,query_obj,with_nested_resources)
        end

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
            get(uri,query_obj,with_nested_resources)
        end

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
            get(uri,query_obj,with_nested_resources)
        end

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
            get(uri,query_obj,with_nested_resources)
        end

        # Modify system Categories.
        #
        # @param data [Single CopyrightPolicies Object, Array of CopyrightPolicies Objects] (Required)
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
            get(uri,query_obj,with_nested_resources)
        end

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
            get(uri,query_obj,with_nested_resources)
        end

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
            get(uri,query_obj,with_nested_resources)
        end

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
            get(uri,query_obj,with_nested_resources)
        end

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
            get(uri,query_obj,with_nested_resources)
        end

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
        #             rest_client.upload_file('/path/to/file','2','10')
        #            rest_client.upload_file('/path/to/file', 2, 10)
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
            timeout = read_timeout.to_i.abs
            timeout = timeout > 0 ? timeout : 120 # 120 sec is the default
            tries   = 1
            response = nil
           
            unless File.exists?(file.to_s)
                msg = "The file #{file.inspect} does not exist...Bailing out."
                logger.error(msg)
                return false
            end

            unless category.is_a?(Categories) || category.to_i > 0
                msg = "Argument Error for upload_files method: Invalid category id passed to second argument.\n" +
                      "Acceptable arguments: Category object, a non-zero numeric String or Integer, " +
                      "or no argument.\nInstead got #{category.class}...Bailing out."
                logger.error(msg)
                return false
            end

            unless project.is_a?(Projects) || project.to_i > 0 || project.to_s.strip.eql?('')
                msg = "Argument Error for upload_files method: Invalid project id passed to third argument.\n" +
                      "Acceptable arguments: Projects object, a non-zero numeric String or Integer, " +
                      "or no argument.\nInstead got a(n) #{project.class} with value => #{project.inspect}...Bailing out."
                      logger.error(msg)    
                return false
            end

            category_id = nil
            project_id  = nil

            if category.is_a?(Categories)
                category_id = category.id
            else
                category_id = category
            end

            if project.is_a?(Projects)
                project_id = project.id
            elsif project.nil?
                project_id = ''
            else
                project_id = project
            end

            uri = URI.parse(@uri + "/Files")
            boundary = (0...50).map { (65 + rand(26)).chr }.join #genererate a random str thats 50 char long
            body = Array.new

            msg = "Uploading File: => {\"original_filename\":\"#{File.basename(file)}\",\"category_id\":\"#{category_id}\",\"project_id\":\"#{project_id}\"}"
            logger.info(msg.white)
            
            # upload waits up to 15 sec to complete before timing out
            loop do
                begin
                    attempts ||= 1
                    response = Net::HTTP.start(uri.host, uri.port, :read_timeout => timeout, :use_ssl => uri.scheme == 'https') do |http|
                        request = Net::HTTP::Post.new(uri.request_uri)

                        if @session
                            request.add_field('X-SessionKey',@session)
                        else
                            @session = @authenticator.get_session
                            request.add_field('X-SessionKey',@session)
                        end
                        request["cache-control"] = 'no-cache'
                        request["content-type"] = 'multipart/form-data; boundary=----WebKitFormBoundary' + boundary
                        body << "------WebKitFormBoundary#{boundary}\r\nContent-Disposition: form-data; name=\"_jsonBody\"" 
                        body << "\r\n\r\n[{\"original_filename\":\"#{File.basename(file)}\",\"category_id\":#{category_id},\"project_id\":\"#{project_id}\"}]\r\n"
                        body << "------WebKitFormBoundary#{boundary}\r\nContent-Disposition: form-data; name=\"file\";"
                        body << "filename=\"#{File.basename(file)}\"\r\nContent-Type: #{MIME::Types.type_for(file)}\r\n\r\n"
                        body << IO.binread(file)
                        body << "\r\n------WebKitFormBoundary#{boundary}--"
                        request.body = body.join
                        http.request(request)
                    end 
                rescue Exception => e 
                    
                    logger.warn("Initial Connection failed. Retrying in 20 seconds.") if attempts.eql?(1)
                    if attempts.eql?(1)
                        20.times do |num|
                            printf("\rRetrying in %-2.0d",(20-num)) 
                            sleep(1)
                        end
                        attempts += 1
                        retry
                    end
                    if e.message.include?("incompatible character encodings")
                        # This means a bad character was found in the file path
                        e.message += ". Check file path in the spreadsheet and compare it with the file system."
                    end
                    logger.error("Connection failed: #{e}")
                    Thread.current.exit
                end

                if response.body.include?('<title>OpenAsset - Something went wrong!</title>') && response.code != '403' 
                    response.body = {
                        'error_message' => 'Possible Gateway timeout: NGINX Error - OpenAsset - Something went wrong!',
                        'http_status_code' => "#{response.code}" }.to_json
                    if tries < 3 
                        tries += 1
                        logger.error("Apache fell behind and NGINX is returning it's infamous error. Waiting 30 seconds before trying again.")
                        sleep(30)
                        redo
                    else
                        logger.error("Made 3 failed attempts. Apache may be down or took way too long to respond. (NGINX ERROR PAGE RETURNED)")
                    end
                end

                response = Validator.process_http_response(response,@verbose,'Files','POST')
                break   
            end

            if generate_objects
                
                data = Files.new
                data.id = 'n/a'
                data.filename = File.basename(file)

                res = process_errors(data,response,'Files','Create')

                generate_objects_from_json_response_body(res,'Files')

            else
                # JSON Object
                response
            end
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

            file_object = (original_file_object.is_a?(Array)) ? original_file_object.first : original_file_object
            uri = URI.parse(@uri + "/Files")
            id = file_object.id.to_s
            original_filename = nil

            # raise an Error if something other than an file object is passed in. Check the class
            unless file_object.is_a?(Files) 
                msg = "Argument Error: First argument => Invalid object type! Expected File object" +
                      " and got #{file_obj.class} object instead. Aborting update."
                logger.error(msg)
                return
            end
            
            if File.directory?(replacement_file_path)
                msg = "Argument Error: Second argument => Expected a file! " +
                      "#{replacement_file_path} is a directory! Aborting update."
                logger.error(msg)
                return
            end


            #check if the replacement file exists
            unless File.exists?(replacement_file_path) && File.file?(replacement_file_path)
                msg = "The file #{replacement_file_path} does not exist. Aborting update."
                logger.error(msg)
                return
            end

            #verify that both files have the same file extentions otherwise you will
            #get a 400 Bad Request Error
            if File.extname(file_object.original_filename) != File.extname(replacement_file_path)
                msg = "File extensions must match! Aborting update\n    " + 
                      "Original file extension => #{File.extname(file_object.original_filename)}\n    " +
                      "Replacement file extension => #{File.extname(replacement_file_path)}"
                logger.error(msg)
                return
            end

            #verify that the original file id is provided
            unless id.to_s != "0"
                msg = "Invalid target file id! Aborting update."
                logger.error(msg)
                return
            end

            #change in format
            if retain_original_filename_in_oa == true
                unless file_object.original_filename == nil || file_object.original_filename == ''
    
                    original_filename = File.basename(file_object.original_filename)
                else
                    msg = "No original filename detected in Files object. Aborting update."
                    logger.error(msg)
                    return
                end
            else
                original_filename = File.basename(replacement_file_path)
            end 

            body = Array.new

            begin
                attempts ||= 1
                response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
                    request = Net::HTTP::Put.new(uri.request_uri)
                    request["content-type"] = 'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW'
                    if @session
                        request.add_field('X-SessionKey',@session)
                    else
                        @session = @authenticator.get_session
                        request.add_field('X-SessionKey',@session)
                    end
                    request["cache-control"] = 'no-cache'
                    body << "------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"_jsonBody\""  
                    body << "\r\n\r\n[{\"id\":\"#{id}\",\"original_filename\":\"#{original_filename}\"}]\r\n"
                    body << "------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"file\";" 
                    body << "filename=\"#{original_filename}\"\r\nContent-Type: #{MIME::Types.type_for(original_filename)}\r\n\r\n"
                    body << IO.binread(replacement_file_path)
                    body << "\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW--"
                    request.body = body.join
                    http.request(request)
                end
            rescue Exception => e
                
                logger.warn("Initial Connection failed. Retrying in 15 seconds.") if attempts.eql?(1)
                if attempts.eql?(1)
                    180.times do |num|
                        printf("\rRetrying in %-2.0d seconds",(180-num)) 
                        sleep(1)
                    end
                    attempts += 1
                    retry
                end
                if e.message.include?("incompatible character encodings")
                    # This means a bad character was found in the file path
                    e.message += ". Check file path in the spreadsheet and compare it with the file system."
                end
                logger.error("Connection failed: #{e}")
                Thread.current.exit
            end

            Validator.process_http_response(response,@verbose,'Files', 'PUT')

            if generate_objects
                
                generate_objects_from_json_response_body(response,'Files')

            else
                # JSON Object
                response
            end
                
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
        
            return if albums.to_s.eql?('') && files.to_s.eql?('')
            # Get album objects
            if albums.is_a?(String) || albums.is_a?(Integer)
                
                ids = albums.to_s.split(/,/).reject { |v| v.strip.empty? || v.to_i.eql?(0) }
                op = RestOptions.new
                op.add_option('id',ids)
                albums = get_albums(op)
                op.clear
            elsif albums.is_a?(Array)
                if albums.first.is_a?(String) || albums.first.is_a?(Integer)
                    op = RestOptions.new
                    op.add_option('id',albums)
                    albums = get_albums(op) 
                    op.clear
                    return false if albums.empty?
                end
                unless albums.first.is_a?(Albums) || albums.first.is_a?(String) || albums.first.is_a?(Integer)
                    logger.error("Expected Albums object(s), string id(s), array of id(s) for first argument. Instead Got => #{albums.to_s.inspect}.")
                    return false
                end
            end

            if albums.empty?
                logger.error("Album insertion error: Album(s) not found in OpenAsset.")
                return false
            end
            logger.info("Retrieved album(s).")


            # Get File objects
            if files.is_a?(String) || files.is_a?(Integer)
                ids = files.to_s.split(/,/).reject { |v| v.strip.empty? || v.to_i.eql?(0) }
                op = RestOptions.new
                op.add_option('id',ids)
                files = get_files(op)
                op.clear
            elsif files.is_a?(Array)
                if files.first.is_a?(String) || files.first.is_a?(Integer)
                    op = RestOptions.new
                    op.add_option('id',files)
                    files = get_albums(op) 
                    op.clear
                    return false if files.empty?
                end
                unless files.first.is_a?(Files) || files.first.is_a?(String) || files.first.is_a?(Integer)
                    logger.error("Expected Files object(s), string id(s), array of id(s) for second argument. Instead Got => #{files.to_s.inspect}.")
                    return false
                end
            end
    
            if files.empty?
                logger.error("Album insertion error: File(s) not found in OpenAsset.")
                return false
            end
            logger.info("Retrieved album(s).")

            # Loop through albums and add files
            logger.info("Adding files to album.")
            albums.each do |album|
                uri = URI.parse(@uri + "/Albums" + "/#{album.id}" + "/Files")
                res = post(uri,files,false)      
                return false unless res.kind_of?(Net::HTTPSuccess)
            end
            return true
        end

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
        
        ##########
        #        #
        # GROUPS #
        #        #
        ##########

        # Retrieves Groups.
        #
        # @param query_obj[RestOptions Object] Specify query parameters string (Optional)
        # @return [JSON object] HTTP response JSON object.
        #
        # @example 
        #          rest_client.get_groups()
        #          rest_client.get_groups(rest_options_object)
        def get_groups(query_obj=nil,with_nested_resources=false)
            uri = URI.parse(@uri + "/Groups")
            get(uri,query_obj,with_nested_resources)
        end

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
            get(uri,query_obj,with_nested_resources)
        end

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
            get(uri,query_obj,with_nested_resources)
        end

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
            get(uri,query_obj,with_nested_resources)
        end

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
            get(uri,query_obj,with_nested_resources)
        end

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
            get(uri,query_obj,with_nested_resources)
        end

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
            get(uri,query_obj,with_nested_resources)
        end

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
            get(uri,query_obj,with_nested_resources)
        end

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
            get(uri,query_obj,with_nested_resources)
        end

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
            get(uri,query_obj,with_nested_resources)
        end

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
            get(uri,query_obj,with_nested_resources)
        end

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
        
            #1.validate class types
            #Looking for File objects or an array of File objects
            unless files.is_a?(Files) || (files.is_a?(Array) && files.first.is_a?(Files))
                warn "Argument Error: Invalid type for first argument in \"file_add_keywords\" method.\n" +
                     "    Expected one the following:\n" +
                     "    1. Single Files object\n" +
                     "    2. Array of Files objects\n" +
                     "    Instead got => #{files.inspect}"
                return false            
            end 

            unless keywords.is_a?(Keywords) || (keywords.is_a?(Array) && keywords.first.is_a?(Keywords))
                warn "Argument Error: Invalid type for second argument in \"file_add_keywords\" method.\n" +
                     "    Expected one the following:\n" +
                     "    1. Single Keywords object\n" +
                     "    2. Array of Keywords objects\n" +
                     "    Instead got => #{keywords.inspect}"
                return false            
            end 
            
            #2.build file json array for request body
            #There are four acceptable combinations for the arguments.
         
            if files.is_a?(Files)  
                if keywords.is_a?(Keywords) #1. Two Single objects
                    uri = URI.parse(@uri + "/Files/#{files.id}/Keywords/#{keywords.id}")
                    post(uri,{})
                else                        #2. One File object and an array of Keywords objects
                    #loop through keywords objects and append the new nested keyword to the file

                    simple_file_obj = Files.new
                    simple_file_obj.id = files.id
                    simple_file_obj.keywords = files.keywords  # retain existing keyword associations

                    keywords.each do |keyword|
                        simple_file_obj.keywords << NestedKeywordItems.new(keyword.id)
                    end
                     
                    uri = URI.parse(@uri + "/Files")
                    put(uri,simple_file_obj,false)
                end
            else        
                if keywords.is_a?(Array)    #3. Two arrays
                    keywords.each do |keyword|
                        uri = URI.parse(@uri + "/Keywords/#{keyword.id}/Files")
                        data = files.map { |files_obj| {:id => files_obj.id} }
                        post(uri,data)
                    end
                else                        #4. Files array and a single Keywords object
                    uri = URI.parse(@uri + "/Keywords/#{keywords.id}/Files")
                    data = files.map { |files_obj| {:id => files_obj.id} }
                    post(uri,data)
                end
            end
            
        end

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
            
            #1.validate class types
            #Looking for Project objects or an array of Project objects
            unless projects.is_a?(Projects) || (projects.is_a?(Array) && 
                    projects.first.is_a?(Projects))
                warn "Argument Error: Invalid type for first argument in \"project_add_keywords\" method.\n" +
                     "    Expected one the following:\n" +
                     "    1. Single Projects object\n" +
                     "    2. Array of Projects objects\n" +
                     "    Instead got => #{projects.inspect}"
                return false            
            end 

            unless proj_keywords.is_a?(ProjectKeywords) || (proj_keywords.is_a?(Array) && 
                    proj_keywords.first.is_a?(ProjectKeywords))
                warn "Argument Error: Invalid type for second argument in \"project_add_keywords\" method.\n" +
                     "    Expected one the following:\n" +
                     "    1. Single ProjectKeywords object\n" +
                     "    2. Array of ProjectKeywords objects\n" +
                     "    Instead got => #{proj_keywords.inspect}"
                return false            
            end 
            #2.build project json array for request body
            #There are four acceptable combinations for the arguments.
            #project_keyword = Struct.new(:id)

            if projects.is_a?(Projects)  
                if proj_keywords.is_a?(ProjectKeywords) #1. Two Single objects
                    uri = URI.parse(@uri + "/Projects/#{projects.id}/ProjectKeywords/#{proj_keywords.id}")
                    post(uri,{},false)
                else                        #2. One Project object and an array of project Keyword objects
                    #loop through Projects objects and append the new nested keyword to them
                    proj_keywords.each do |keyword|
                        #projects.project_keywords << project_keyword.new(keyword.id)
                        projects.project_keywords << NestedProjectKeywordItems.new(proj_keywords.id)  
                    end
                    uri = URI.parse(@uri + "/Projects")
                    put(uri,projects,false)
                end
            else         
                if proj_keywords.is_a?(Array)    #3. Two arrays
                    projects.each do |proj|
                        proj_keywords.each do |keyword|
                            #proj.project_keywords << project_keyword.new(keyword.id)
                            proj.project_keywords << NestedProjectKeywordItems.new(proj_keywords.id)
                        end
                    end
                    uri = URI.parse(@uri + "/Projects")
                    put(uri,projects,false)
                else                        #4. Projects array and a single Keywords object
                    projects.each do |proj|
                        #proj.project_keywords << project_keyword.new(proj_keywords.id)
                        proj.project_keywords << NestedProjectKeywordItems.new(proj_keywords.id)
                    end    
                    uri = URI.parse(@uri + "/Projects") #/ProjectKeywords/:id/Projects 
                    put(uri,projects,false)                    #shortcut not implemented yet                    
                end
            end
        end

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
            
            #validate class types
            unless file.is_a?(Files) || (file.is_a?(String) && (file.to_i != 0)) || file.is_a?(Integer)
                warn "Argument Error: Invalid type for first argument in \"file_add_field_data\" method.\n" +
                     "    Expected Single Files object, Numeric string, or Integer for file id\n" +
                     "    Instead got => #{file.inspect}"
                return            
            end 

            unless field.is_a?(Fields) ||  (field.is_a?(String) && (field.to_i != 0)) || field.is_a?(Integer)
                warn "Argument Error: Invalid type for second argument in \"file_add_field_data\" method.\n" +
                     "    Expected Single Fields object, Numeric string, or Integer for field id\n" +
                     "    Instead got => #{field.inspect}"
                return             
            end

            unless value.is_a?(String) || value.is_a?(Integer) || value.is_a?(Float)
                warn "Argument Error: Invalid type for third argument in \"file_add_field_data\" method.\n" +
                     "    Expected a String, Integer, or Float\n" +
                     "    Instead got => #{value.inspect}"
                return            
            end

            res           = nil
            current_file  = nil
            current_field = nil
            current_value = value.to_s.strip

            file_class  = file.class.to_s
            field_class = field.class.to_s

            #set up objects
            if file_class == 'Files'
                current_file = file
            elsif file_class == 'String' || file_class == 'Integer' 
                #retrieve Projects object matching id provided
                uri = URI.parse(@uri + "/Files")
                option = RestOptions.new
                option.add_option("id",file.to_s)
                current_file = get(uri,option).first
                unless current_file
                    warn "ERROR: Could not find Project with matching id of \"#{file.to_s}\"...Exiting"
                    return
                end
            else
                warn "Unknown Error retrieving Files. Exiting."
                return
            end

            if field_class == 'Fields'
                current_field = field
            elsif field_class == 'String' || field_class == 'Integer'
                uri = URI.parse(@uri + "/Fields")
                option = RestOptions.new
                option.add_option("id",field.to_s)
                current_field = get(uri,option).first
                unless current_field
                    warn "ERROR: Could not find Field with matching id of \"#{field.to_s}\"\n" +
                         "=> Hint: It either doesn't exist or it's disabled."
                    return false
                end
                unless current_field.field_type == "image"
                    warn "ERROR: Expected a Project field. The field provided is a \"#{current_field.field_type}\" field."
                    return false
                end        
            else
                warn "Unknown Error retrieving Field. Exiting."
                return
            end

            #Prep endpoint to be used for update
            files_endpoint = URI.parse(@uri + "/Files/#{current_file.id}/Fields")

            #Check the field type -> if its option or fixed suggestion we must make the option
            #available first before we can apply it to the Files resource
            if RESTRICTED_LIST_FIELD_TYPES.include?(current_field.field_display_type)
                
                lookup_string_endpoint = URI.parse(@uri + "/Fields/#{current_field.id}/FieldLookupStrings")

                #Grab all the available FieldLookupStrings for the specified Fields resource
                field_lookup_strings = get(lookup_string_endpoint,nil)

                #check if the value in the third argument is currently an available option for the field
                lookup_string_exists = field_lookup_strings.find { |item| current_value.downcase == item.value.downcase }

                # add the option to the restricted field first if it's not there, otherwise you get a 400 bad 
                # request error saying that it couldn't find the string value for the restricted field specified 
                # when making a PUT request on the FILES resource you are currently working on
                unless lookup_string_exists
                    data = {:value => current_value }
                    response = post(lookup_string_endpoint,data,false)
                    unless response.kind_of?(Net::HTTPSuccess)
                        return
                    end
                end

                # Now that we know the option is available, we can update the File we are currently working with
                index = current_file.fields.find_index { |nstd_field| nstd_field.id.to_s == current_field.id.to_s }

                if index
                    current_file.fields[index].values = [current_value]
                else
                    current_file.fields << NestedFieldItems.new(current_field.id,[current_value])
                end

                res = update_files(current_file,false)

            elsif current_field.field_display_type == "date"
                #make sure we get the right date format
                #Accepts mm-dd-yyyy, mm-dd-yy, mm/dd/yyyy, mm/dd/yy
                date_regex = Regexp::new('((\d{2}-\d{2}-(\d{4}|\d{2}))|(\d{2}\/\d{2}\/(\d{4}|\d{2})))')
                unless (value =~ date_regex) == 0
                    warn "ERROR: Invalid date format. Expected => \"mm-dd-yyyy\" or \"mm-dd-yy\""
                    return
                end

                value.gsub!('/','-')
                date_arr = value.split('-') #convert date string to array for easy manipulation

                if date_arr.last.length == 2  #convert mm-dd-yy to mm-dd-yyyy format
                    four_digit_year = '20' + date_arr.last
                    date_arr[-1] = four_digit_year
                end
                #convert date to 14 digit unix time stamp
                value = date_arr[-1] + date_arr[-3] + date_arr[-2] + '000000'

                #Apply the date to our current Files resource
                data = {:id => current_field.id, :values => [value.to_s]}
                res = put(files_endpoint,data,false)


            elsif NORMAL_FIELD_TYPES.include?(current_field.field_display_type)
                #some fields are built into Files so they can't be inserted into
                #the Files nested fields resource. We get around this by using the
                #name of the field object to access the corresponding built-in field attribute
                #inside the Files object.
                if current_field.built_in.to_s == "1"  #For built in fields
                    files_endpoint =  URI.parse(@uri + '/Files') #change endpoint bc field is built_in
                    field_name = current_field.name.downcase.gsub(' ','_') #convert the current field's name
                                                                           #into the associated files' built_in attribute name
                    
                    #access built-in field
                    unless current_file.instance_variable_defined?('@'+field_name)
                        warn "ERROR: The specified attirbute \"#{field_name}\" does not" + 
                             " exist in the File. Exiting."
                        exit
                    end
                    
                    current_file.instance_variable_set('@'+field_name, value)
                    res = put(files_endpoint,current_file,false)
                else    #For regular non-built in fields

                    data = {:id => current_field.id, :values => [value.to_s]}
                    endpoint = URI.parse(@uri + "/Files" + "/#{current_file.id}" + "/Fields")
                    res = put(endpoint,data,false)
                    
                end

            elsif current_field.field_display_type == 'boolean'

                #validate value
                unless ALLOWED_BOOLEAN_FIELD_OPTIONS.include?(value.to_s.strip)
                    msg = "Invalid value #{value.inspect} for \"On/Off Switch\" field type.\n" +
                          "Acceptable Values => #{ALLOWED_BOOLEAN_FIELD_OPTIONS.inspect}"
                    logger.error(msg)
                    return
                end
                
                
                #Interpret input
                #Even indicies in the field options array are On and Odd indicies are Off
                bool_val = ""
                if ALLOWED_BOOLEAN_FIELD_OPTIONS.find_index(value.to_s.strip).even?
                    bool_val = "1"
                elsif ALLOWED_BOOLEAN_FIELD_OPTIONS.find_index(value.to_s.strip).odd?
                    bool_val = "0"
                end

                #Prep the endpoint
                files_endpoint =  URI.parse(@uri + '/Files')

                current_file.fields.each do |obj| 
                    if obj.id == current_field.id
                        obj.values[0] = bool_val
                    end
                    
                end
                
                #Actually do the update
                res = put(files_endpoint,current_file,false)
            else
                msg = "The field specified does not have a valid field_display_type." +
                      "Value provided => #{field.field_display_type.inspect}"
                logger.error(msg)
                return
            end

            if @verbose
                msg = "Setting value: \"#{current_value}\" to \"#{current_field.name}\" field " +
                      "for file => #{current_file.filename}"
                logger.info(msg.green)
            end
            return res
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

            #validate class types
            unless project.is_a?(Projects) || (project.is_a?(String) && (project.to_i != 0)) || project.is_a?(Integer)
                warn "Argument Error: Invalid type for first argument in \"project_add_field_data\" method.\n" +
                     "    Expected Single Projects object, a Numeric string or Integer for a Project id\n" +
                     "    Instead got => #{project.inspect}"
                return            
            end 

            unless field.is_a?(Fields) ||  (field.is_a?(String) && (field.to_i != 0)) || field.is_a?(Integer)
                warn "Argument Error: Invalid type for second argument in \"project_add_field_data\" method.\n" +
                     "    Expected Single Projects object, Numeric string, or Integer for Projects id.\n" +
                     "    Instead got => #{field.inspect}"
                return            
            end

            unless value.is_a?(String) || value.is_a?(Integer)
                warn "Argument Error: Invalid type for third argument in \"project_add_field_data\" method.\n" +
                     "    Expected a String or an Integer.\n" +
                     "    Instead got => #{value.inspect}"
                return            
            end

            #NOTE: Date fields use the mm-dd-yyyy format
            current_project = nil
            current_field   = nil
            current_value    = value.to_s.strip

            project_class  = project.class.to_s
            field_class    = field.class.to_s
            res            = nil
            #set up objects
            if project_class == 'Projects'
                current_project = project
            elsif project_class == 'String' || project_class == 'Integer' 
                #retrieve Projects object matching id provided
                uri = URI.parse(@uri + "/Projects")
                option = RestOptions.new
                option.add_option("id",project.to_s)
                current_project = get(uri,option).first
                unless current_project
                    warn "ERROR: Could not find Project with matching id of \"#{project.to_s}\"...Exiting"
                    return
                end
            else
                warn "Unknown Error retrieving project. Exiting."
                return
            end

            if field_class == 'Fields'
                current_field = field
            elsif field_class == 'String' || field_class == 'Integer'
                uri = URI.parse(@uri + "/Fields")
                option = RestOptions.new
                option.add_option("id",field.to_s)
                current_field = get(uri,option).first
                unless current_field
                    warn "ERROR: Could not find Field with matching id of \"#{field.to_s}\"\n" +
                         "=> Hint: It either doesn't exist or it's disabled."
                    return 
                end
                unless current_field.field_type == "project"
                    warn "ERROR: Expected a Project field. The field provided is a \"#{current_field.field_type}\" field."
                    return 
                end        
            else
                warn "Unknown Error retrieving field. Exiting."
                return
            end

            #Prep endpoint shortcut to be used for update
            projects_endpoint = URI.parse(@uri + "/Projects/#{current_project.id}/Fields")

            #Check the field type -> if its option or fixed suggestion we must make the option
            #available first before we can apply it to the Files resource
            if RESTRICTED_LIST_FIELD_TYPES.include?(current_field.field_display_type)
                
                lookup_string_endpoint = URI.parse(@uri + "/Fields/#{current_field.id}/FieldLookupStrings")

                #Grab all the available FieldLookupStrings for the specified Fields resource
                field_lookup_strings = get(lookup_string_endpoint,nil)

                #check if the value in the third argument is currently an available option for the field
                lookup_string_exists = field_lookup_strings.find { |item| item.value == value }

                #add the option to the restricted field first if it's not there, otherwise you get a 400 bad 
                #request error saying that it couldn't find the string value for the restricted field specified 
                #when making a PUT request on the PROJECTS resource you are currently working on
                unless lookup_string_exists
                    data = {:value => value}
                    response = post(lookup_string_endpoint,data,false)
                    return unless response.kind_of? Net::HTTPSuccess
                end

                #Now that we know the option is available, we can update the Project
                index = current_project.fields.find_index { |nested_field| nested_field.id.to_s == current_field.id.to_s }
                
                if index
                    current_project.fields[index].values = [value]
                else
                    current_project.fields << NestedFieldItems.new(current_field.id,[value])
                end

                res = update_projects(current_project,false)

                #data = {:id => current_field.id, :values => [value.to_s]}
                #put(projects_endpoint,data,false)

                if @verbose
                    msg = "Adding value: \"#{value}\" to \"#{current_field.name}\" field" +
                          "for project => #{current_project.code} - #{current_project.name}"
                    logger.info(msg.green)
                end

            elsif current_field.field_display_type == "date"
                #make sure we get the right date format
                #Accepts mm-dd-yyyy, mm-dd-yy, mm/dd/yyyy, mm/dd/yy
                date_regex = Regexp::new('((\d{2}-\d{2}-(\d{4}|\d{2}))|(\d{2}\/\d{2}\/(\d{4}|\d{2})))')
                unless (value =~ date_regex) == 0
                    msg = "Invalid date format. Expected => \"mm-dd-yyyy\" or \"mm-dd-yy\""
                    logger.error(msg)
                    return
                end

                value.gsub!('/','-')
                date_arr = value.split('-') #convert date string to array for easy manipulation

                if date_arr.last.length == 2  #convert mm-dd-yy to mm-dd-yyyy format
                    four_digit_year = '20' + date_arr.last

                    date_arr[-1] = four_digit_year
                end
                #convert date to 14 digit unix time stamp
                value = date_arr[-1] + date_arr[-3] + date_arr[-2] + '000000'

                #Apply the date to our current Files resource
                data = {:id => current_field.id, :values => [value.to_s]}
                res = put(projects_endpoint,data,false) #Make the update
              

            elsif NORMAL_FIELD_TYPES.include?(current_field.field_display_type) #For regular fields
                #some fields are built into Projects so they can't be inserted into
                #the Projects nested fields resource. We get around this by using the
                #name of the field object to access the corresponding built-in field attribute
                #inside the Projects object.
              
                if current_field.built_in.to_s == "1"  #For built in fields
                    projects_endpoint =  URI.parse(@uri + '/Projects') #change endpoint bc field is built_in
                    field_name = current_field.name.downcase.gsub(' ','_')
                    
                    unless current_project.instance_variable_defined?('@'+field_name)
                        warn "ERROR: The specified attirbute \"#{field_name}\" does not" + 
                             " exist in the Project. Exiting."
                        exit(-1)
                    end
                    #update the project
                    current_project.instance_variable_set('@'+field_name, value)
                    #Make the update request
                    res = put(projects_endpoint,current_project,false)                 

                else                                                        #For regular non-built in fields
                    data = {:id => current_field.id, :values => [value.to_s]}
                    res = put(projects_endpoint,data,false)
                end
               
            elsif current_field.field_display_type == 'boolean'

                #validate value
                unless ALLOWED_BOOLEAN_FIELD_OPTIONS.include?(value.to_s.strip)
                    msg = "Error: Invalid value #{value.inspect} for \"On/Off Switch\" field type.\n" +
                          "Acceptable Values => #{ALLOWED_BOOLEAN_FIELD_OPTIONS.inspect}"
                    logger.error(msg)
                    return
                end
                
                #Interpret input
                #Even indicies in the field options array are On and Odd indicies are Off
                bool_val = ""
                if ALLOWED_BOOLEAN_FIELD_OPTIONS.find_index(value.to_s.strip).even?
                    bool_val = "1"
                elsif ALLOWED_BOOLEAN_FIELD_OPTIONS.find_index(value.to_s.strip).odd?
                    bool_val = "0"
                end
                
                #Update the object
                projects_endpoint =  URI.parse(@uri + '/Projects')

                current_project.fields.each do |obj| 
                    if obj.id == current_field.id
                        obj.values[0] = bool_val
                    end
                    #obj
                end
                
                #Update current value variable for @verbose statement below
                current_value = bool_val

                #Acutally perform the update request
                res = put(projects_endpoint,current_project,false)
                
            else
                warn "Error: The field specified does not have a valid field_display_type." +
                     "Value provided => #{field.field_display_type.inspect}"
            end

            if @verbose
                msg = "Setting value: \"#{current_value}\" to \"#{current_field.name}\" field " +
                      "for project => #{current_project.code} - #{current_project.name}"
                logger.info(msg.green)
            end
            return res
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
            
            # Validate input:
            args = process_field_to_keyword_move_args('albums',
                                                       album,
                                                       target_keyword_category,
                                                       source_field,
                                                       field_separator,
                                                       batch_size)

            album_found                 = args.container
            file_keyword_category_found = args.target_keyword_category
            source_field_found          = args.source_field

            total_file_count            = nil
            built_in                    = nil
            file_ids                    = nil
            file_category_ids           = nil
            keyword_file_category_ids   = nil
            existing_keyword_categories = nil
            existing_keywords           = nil
            cat_id_string               = nil
            batch_size                  = batch_size.to_i.abs

            limit                       = batch_size # For better readability
            total_files_updated         = 0
            offset                      = 0
            iterations                  = 0
            files                       = []

            op                          = RestOptions.new

            # Get total file count
            total_file_count = album_found.files.length
            
            # Check the source_field field type
            built_in = (source_field_found.built_in == '1') ? true : false

            # Get all the categories associated with the files in the project then using the target_keyword_category,  
            # create the file keyword category in all the system categories that don't have them
            file_ids = album_found.files.map { |obj| obj.id }

            op.add_option('limit','0')
            op.add_option('id', file_ids.join(',')) #create query string from file id array
            op.add_option('displayFields','category_id')

            # Get categories found in album
            file_category_ids = get_files(op).uniq { |obj| obj.category_id }.map { |obj| obj.category_id.to_s }

            op.clear

            # Get the keyword categories associated with the files in the album
            cat_id_string = file_category_ids.join(',')
            op.add_option('limit', '0')
            op.add_option('category_id', cat_id_string)
            existing_keyword_categories = get_keyword_categories(op)
            
            op.clear

            # Check if any of the system categories found in the album DO NOT CONTAIN 
            # the target_keyword_category name and create it
            keyword_file_category_ids = existing_keyword_categories.reject do |obj| 
                obj.name.downcase != file_keyword_category_found.name 
            end.map do |obj| 
                obj.category_id.to_s 
            end.uniq

            # Make sure the keyword category is in all associated categories
            # Now loop throught the file categories, create the needed keyword categories for referencing below
            msg = "Creating keyword categories."
            logger.info(msg.green)

            file_category_ids.each do |file_cat_id|
                
                # Look for the category id in existing keyword categories to check 
                # if the file category already has a keyword category with that name
                unless keyword_file_category_ids.include?(file_cat_id.to_s)
                    msg = "Actually creating keyword categories..."
                    logger.info(msg.green)

                    obj = KeywordCategories.new(file_keyword_category_found.name, file_cat_id)
                    kwd_cat_obj = create_keyword_categories(obj, true).first
                    
                    unless kwd_cat_obj
                        msg = "Error creating keyword category in #{__callee__}"
                        logger.error(msg)
                        abort
                    end
                    
                    existing_keyword_categories.push(kwd_cat_obj)
                    
                else
                    msg = "Keyword category in category #{file_cat_id} already exists"
                    logger.warn(msg.yellow)
                end

            end

    
            # Get all file keywords for the keyword category name associated with all the file categories found in the album
            query_ids = existing_keyword_categories.map { |item| item.id }.join(',')
            
            op.add_option('keyword_category_id', query_ids)
            op.add_option('limit', '0')

            msg = "Getting existing keywords"
            logger.info(msg.green)

            existing_keywords = get_keywords(op)

            op.clear
            
            # Calculate number of requests needed based on specified batch_size
            msg = "Setting batch size."
            logger.info(msg.green)

            if total_file_count % batch_size == 0
                iterations = total_file_count / batch_size
            else
                iterations = total_file_count / batch_size + 1  #we'll need one more iteration to grab remaining
            end

            # Create update loop using iteration limit and batch size
            iterations.times do |num|

                num += 1
                
                # More efficient than setting the offset and limit in the query
                start_index = offset
                end_index   = offset + limit
                ids = file_ids[start_index...end_index].join(',')

                op.add_option('id', ids)
                op.add_option('keywords','all')
                op.add_option('fields','all')
                # Get current batch of files => body length used to track total files updated
                msg = "Batch #{num} of #{iterations} => Retrieving files."
                logger.info(msg.green)

                files = get_files(op)

                op.clear

                msg = "Batch #{num} of #{iterations} => Extracting keywords from \"#{source_field_found.name}\" field."
                logger.info(msg)

                keywords_to_create = []
                
                # Iterate through the files and find the keywords that need to be created
                files.each do |file|
                    
                    field_data      = nil
                    field_obj_found = nil

                    # Check if the field has any data in it
                    if built_in
                        field_name = source_field_found.name.downcase.gsub(' ','_')
                        #puts "Field name 1 : #{field_name}"
                        field_data = file.instance_variable_get("@#{field_name}")
                        field_data = field_data.strip # In case a bunch of spaces are stored in the field
                        next if field_data.nil? || field_data == ''
                    else
                        field_obj_found = file.fields.find { |f| f.id == source_field_found.id }
                        if field_obj_found.nil? || field_obj_found.values.first.nil? || field_obj_found.values.first.strip == ''
                            next
                        end
                        field_data = field_obj_found.values.first
                    end

                    # Split the string using the specified separator and remove empty strings
                    keywords_to_append = field_data.split(field_separator).reject { |val| val.to_s.strip.empty? }

                    # establish link between keyword and current file
                    associated_kwd_cat = existing_keyword_categories.find do |obj| 
                        
                        obj.name.downcase == file_keyword_category_found.name.downcase && 
                        obj.category_id.to_s == file.category_id.to_s
         
                    end           

                    keywords_to_append.each do |val|
        
                        val = val.strip.gsub("\u00A9",'(c)').encode("iso-8859-1", invalid: :replace, undef: :replace)

                        # Check if the value exists in existing keywords
                        keyword_found_in_existing = existing_keywords.find do |k|
                            
                            # Match the existing keywords check by the name and the category
                            # id of the current file to establish the the link between the two

                            begin
                                # In case we get an invalid input string like "\xA9" => copyright binary representation
                                # The downcase method can choke on this depending on the platform
                                # It works in windows but chokes in linux and possibly mac OS
                                k.name.downcase == val.downcase && k.keyword_category_id == associated_kwd_cat.id
                            rescue
                                k.name == val && k.keyword_category_id == associated_kwd_cat.id
                            end
                        end                        

                        if !keyword_found_in_existing

                            # Insert into keywords_to_create array
                            obj = Keywords.new(associated_kwd_cat.id, val)
                            keywords_to_create.push(obj)
                            
                        end
                    end
                end        
                
                # Remove duplicate keywords in the same keyword category and create them
                unless keywords_to_create.empty?
                    payload = keywords_to_create.uniq { |item| [item.name, item.keyword_category_id] }
                    
                    # Create the keywords for the current batch and set the generate objects flag to true.
                    msg = "Batch #{num} of #{iterations} => creating keywords."
                    logger.info(msg.green)

                    new_keywords = create_keywords(payload, true)
                    # Append the returned keyword objects to the existing keywords array
                    if new_keywords
                        if new_keywords.is_a?(Array) && !new_keywords.empty?     
                            new_keywords.each do |item| 
                                existing_keywords.push(item) unless item.is_a?(Error)
                            end
                        else
                            msg = "An error occured creating keywords in #{__callee__}"
                            logger.error(msg)
                            abort
                        end
                    end
                end

                # Loop though the files again and tag them with the newly created keywords.
                # This is faster than making individual requests
                msg = "Batch #{num} of #{iterations} => Tagging files with keywords."
                logger.info(msg.green)

                files.each do | file |
                    #puts "In files tag before using instance_variable_get 2"
                    field_data = nil
                    file.original_filename = nil
                    file.caption.to_s.gsub!(/\n+/,' ')

                    # Look for the field and check if the field has any data in it
                    if built_in
                        field_name = source_field_found.name.downcase.gsub(' ','_')
                        field_data = file.instance_variable_get("@#{field_name}")
                        field_data = field_data.strip
                        next if field_data.nil? || field_data == ''
                    else
                        field_obj_found = file.fields.find { |f| f.id.to_s == source_field_found.id.to_s }
                        if field_obj_found.nil? || field_obj_found.values.first.nil? || field_obj_found.values.first.strip == ''
                            next
                        end
                        field_data = field_obj_found.values.first
                    end

                    if field_data
                        
                        # Split the string using the specified separator and remove empty strings
                        keywords = field_data.split(field_separator).reject { |val| val.to_s.strip.empty? }

                        # ESTABLISH LINK BETWEEN FILE AND KEYWORD
                        associated_kwd_cat = existing_keyword_categories.find do |item|
                            item.name.downcase == file_keyword_category_found.name.downcase &&
                            item.category_id.to_s == file.category_id.to_s
                        end

                        unless associated_kwd_cat
                            msg = "Associated keyword category retrieval failed in #{__callee__}"
                            logger.fatal(msg)
                            abort
                        end

                        # Loop through the keywords and tag the file
                        keywords.each do |value|
                            # Trim leading & trailing whitespace => OA also removes newlines and double spaces during creation
                            value = value.strip.gsub(/[\n\s]+/,' ').gsub("\u00A9",'(c)').encode("iso-8859-1", invalid: :replace, undef: :replace)
                            # Find the string in existing keywords
                            keyword_obj = existing_keywords.find do |item| 
                                begin           
                                    item.name.downcase == value.downcase && associated_kwd_cat.id.to_s == item.keyword_category_id.to_s     
                                rescue
                                    item.name == value && associated_kwd_cat.id.to_s == item.keyword_category_id.to_s
                                end
                            end

                            if keyword_obj
                                #check if current file is already tagged
                                already_tagged = file.keywords.find { |item| item.id.to_s == keyword_obj.id.to_s }
                                # Tag the file
                                unless already_tagged
                                    msg = "Tagging #{file.filename.inspect} => #{keyword_obj.name}"
                                    logger.info(msg.green)

                                    file.keywords.push(NestedKeywordItems.new(keyword_obj.id))
                                end 
                            else
                                msg = "Unable to retrieve previously created keyword! => #{value.inspect} in #{__callee__}"
                                logger.fatal(msg)
                                abort
                            end
                            
                        end
                        
                    end
                end

                msg = "Batch #{num} of #{iterations} => Attempting to perform file updates."
                logger.info(msg.white)

                # Update files
                updated_obj_count = run_smart_update(files,total_files_updated)

                total_files_updated += updated_obj_count

                offset += limit
            end  
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
        #          rest_client.move_file_field_data_to_keywords_by_album(Categories object,KeywordCategories object,Fields object,';',250)
        #          rest_client.move_file_field_data_to_keywords_by_album("Projects","keyword_category_name","file_field_name",';',250)
        #          rest_client.move_file_field_data_to_keywords_by_album("9","1","7",';',250)
        #          rest_client.move_file_field_data_to_keywords_by_album(9,1,7,';',250)
        def move_file_field_data_to_keywords_by_category(category=nil,
                                                        target_keyword_category=nil,
                                                        source_field=nil,
                                                        field_separator=nil,
                                                        batch_size=200)
        
            # Validate input:
            args = process_field_to_keyword_move_args('categories',
                                                       category,
                                                       target_keyword_category,
                                                       source_field,
                                                       field_separator,
                                                       batch_size)
            
            category_found              = args.container
            file_keyword_category_found = args.target_keyword_category
            source_field_found          = args.source_field

            built_in                     = nil
            total_file_count            = nil
            existing_keywords           = nil
            batch_size                  = batch_size.to_i.abs
            iterations                  = 0
            offset                      = 0
            limit                       = batch_size # For better readability
            total_files_updated         = 0
            file_ids                    = nil
            op                          = RestOptions.new

            if file_keyword_category_found.category_id != category_found.id
                msg = "Specified keyword category #{file_keyword_category_found.name.inspect} " +
                      "with id #{file_keyword_category_found.id.inspect} not found in #{category_found.name.inspect}."
                logger.error(msg)
                abort
            end

            # Get ids and total file count for the category
            op.add_option('category_id', category_found.id)
            op.add_option('displayFields', 'id')
            op.add_option('limit','0')
            file_ids = get_files(op).map { |obj| obj.id.to_s  }
            total_file_count = file_ids.length

            msg = "Total file count => #{total_file_count}"
            logger.info(msg.green)

            op.clear    

            # Check field type
            built_in = (source_field_found.built_in == '1') ? true : false

            # Get all file keywords in the specified keyword category
            op.add_option('keyword_category_id', file_keyword_category_found.id)
            op.add_option('limit', '0')
            existing_keywords = get_keywords(op)

            op.clear

            # Calculate number of requests needed based on specified batch_size
            if total_file_count % batch_size == 0
                iterations = total_file_count / batch_size
            else
                iterations = total_file_count / batch_size + 1  #we'll need one more iteration to grab remaining
            end

            # Create update loop using iteration limit and batch size
            iterations.times do |num|

                num += 1

                # More efficient than setting the offset and limit in the query
                start_index = offset
                end_index   = offset + limit
                ids = file_ids[start_index...end_index].join(',')
                
                op.add_option('id',ids)
                op.add_option('limit','0')
                op.add_option('keywords','all')
                op.add_option('fields','all')
                # Get current batch of files
                msg = "[INFO] Batch #{num} of #{iterations} => Retrieving files."
                logger.info(msg.green)

                files = get_files(op)
                
                op.clear

                keywords_to_create = []
                
                msg = "Batch #{num} of #{iterations} => Extracting keywords from #{source_field_found.name.inspect} field."
                logger.info(msg.green)

                # Iterate through the files and find the keywords that need to be created
                files.each do |file|
                    
                    field_data = nil
                
                    # Look for the field and check if it has any data in it
                    if built_in
                        field_name = source_field_found.name.downcase.gsub(' ','_')
                        field_data = file.instance_variable_get("@#{field_name}")
                        field_data = field_data.strip
                        next if field_data.nil? || field_data == ''
                    else
                        field_obj_found = file.fields.find { |f| f.id.to_s == source_field_found.id.to_s }
                        if field_obj_found.nil? || field_obj_found.values.first.nil? || field_obj_found.values.first.strip == ''
                            next
                        end
                        field_data = field_obj_found.values.first
                    end

                    # Split the string using the specified separator and remove empty strings
                    keywords_to_append = field_data.split(field_separator).reject { |val| val.to_s.strip.empty? }

                    keywords_to_append.each do |val|

                        # Remove leading and trailing white space
                        val = val.strip.gsub("\u00A9",'(c)').encode("iso-8859-1", invalid: :replace, undef: :replace)

                        # Check if the value exists in existing keywords
                        keyword_found_in_existing = existing_keywords.find do |k|
                            begin 
                                k.name.downcase == val.downcase 
                            rescue
                                k.name == val
                            end
                        end

                        unless keyword_found_in_existing
                            # Populate list of keywords that need to be created
                            keywords_to_create.push(Keywords.new(file_keyword_category_found.id, val))
                        end
                        
                    end
        
                end
                
                msg = "Batch #{num} of #{iterations} => Creating keywords."
                logger.info(msg.green)

                # Remove duplicate keywords => just in case
                unless keywords_to_create.empty?
                    
                    payload = keywords_to_create.uniq { |item| item.name }
                    # Create the keywords for the current batch and set the generate objects flag to true.
                    new_keywords = create_keywords(payload, true)

                    # Append the returned keyword objects to the existing keywords array
                    if new_keywords
                        if new_keywords.is_a?(Array) && !new_keywords.empty?
                            # new keywords may contain error objects due to duplicates.
                            # Only add non error objects to the collection.
                            new_keywords.each do |item| 
                                existing_keywords.push(item) unless item.is_a?(Error)
                            end
                        else
                            msg = "An error occured creating keywords in #{__callee__}"
                            logger.error(msg)
                            abort
                        end
                    end
                end

                msg = "Batch #{num} of #{iterations} => Tagging files."
                logger.info(msg.green)

                # Loop though the files again and tag them with the newly created keywords.
                files.each do | file |
                    file.original_filename = nil
                    file.caption.to_s.gsub!(/\n+/,' ') # Prevents 400 error when making update
                    field_data = nil

                    #9. Look for the field and check if the field has any data in it
                    if built_in
                        field_name = source_field_found.name.downcase.gsub(' ','_')
                        field_data = file.instance_variable_get("@#{field_name}")
                        field_data = field_data.strip
                        next if field_data.nil? || field_data == ''
                    else
                        field_obj_found = file.fields.find { |f| f.id.to_s == source_field_found.id.to_s }
                        if field_obj_found.nil? || field_obj_found.values.first.nil? || field_obj_found.values.first.strip == ''
                            next
                        end
                        field_data = field_obj_found.values.first
                    end

                    if field_data
                        
                        # Remove empty strings
                        keywords = field_data.split(field_separator).reject { |val| val.to_s.strip.empty? }

                        # Loop through the keywords and tag the file
                        keywords.each do |value|
                            # Trim leading & trailing whitespace and encode it to the same encoding used to create it
                            value = value.strip.gsub(/[\n\s]+/,' ').gsub("\u00A9",'(c)').encode("iso-8859-1", invalid: :replace, undef: :replace)
                            #find the string in existing keywords
                            keyword_obj = existing_keywords.find do |item| 
                                begin
                                    item.name.downcase == value.downcase 
                                rescue
                                    item.name == value 
                                end

                            end

                            if keyword_obj
                                #check if current file is already tagged
                                already_tagged = file.keywords.find { |item| item.id.to_s == keyword_obj.id.to_s }
                                # Tag the file
                                unless already_tagged
                                    msg = "Tagging file #{file.filename.inspect} => #{keyword_obj.name.inspect}"
                                    logger.info(msg.green)
                                    file.keywords.push(NestedKeywordItems.new(keyword_obj.id))
                                end
                            else
                                msg = "Unable to retrieve previously created keyword #{value.inspect} in #{__callee__}"
                                logger.fatal(msg)
                                abort
                            end        
                        end    
                    end
                end

                msg = "Batch #{num} of #{iterations} => Attempting to perform file updates."
                logger.info(msg.white)

                # Update files
                updated_obj_count = run_smart_update(files,total_files_updated)
                
                total_files_updated += updated_obj_count

                offset += limit
            end 
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
        #          rest_client.move_file_field_data_to_keywords_by_album(Projects object,KeywordCategories object,Fields object,';',250)
        #          rest_client.move_file_field_data_to_keywords_by_album("MyProject","keyword category name","file field name",';',250)
        #          rest_client.move_file_field_data_to_keywords_by_album("9","1","7",';',250)
        #          rest_client.move_file_field_data_to_keywords_by_album(9,1,7,';',250)
        def move_file_field_data_to_keywords_by_project(project=nil,
                                                       target_keyword_category=nil,
                                                       source_field=nil,
                                                       field_separator=nil,
                                                       batch_size=200)
            # Validate input:
            args = process_field_to_keyword_move_args('projects',
                                                       project,
                                                       target_keyword_category,
                                                       source_field,
                                                       field_separator,
                                                       batch_size)

            project_found               = args.container
            file_keyword_category_found = args.target_keyword_category
            source_field_found          = args.source_field

            built_in                     = nil
            file_category_ids           = nil
            file_ids                    = nil
            results                     = nil
            existing_keywords           = nil
            existing_keyword_categories = nil
            total_file_count            = 0
            total_files_updated         = 0  # For better readability
            offset                      = 0
            iterations                  = 0
            limit                       = batch_size.to_i.abs
            op                          = RestOptions.new

            cat_id_string               = ''
            query_ids                   = ''
            keyword_file_category_ids   = ''
            
            # Check the source_field field type
            built_in = (source_field_found.built_in == '1') ? true : false
            
            # Get all the categories associated with the files in the project then using the target_keyword_category,  
            # create the file keyword category in all the system categories that don't have them

            # Capture associated system categories
            op.add_option('limit','0')
            op.add_option('project_id',project_found.id)
            op.add_option('displayFields','id,category_id')

            msg = "Retrieving files and file categories associated with project."
            logger.info(msg.green)

            # Get category ids and file ids  
            results           = get_files(op)
            file_category_ids = results.map { |obj| obj.category_id  }.uniq
            file_ids          = results.map { |obj| obj.id }
            total_file_count  = file_ids.length

            op.clear
            
            msg = "Total file count => #{total_file_count}"
            logger.info(msg.green)

            # Get the keyword categories associated with the files in the project
            cat_id_string = file_category_ids.join(',')
            op.add_option('limit', '0')
            op.add_option('category_id', cat_id_string)

            existing_keyword_categories = get_keyword_categories(op)

            op.clear

            # Check if any of the file categories found in the project DO NOT CONTAIN 
            # the target_keyword_category name and create it
            keyword_file_category_ids = existing_keyword_categories.map { |obj| obj.category_id.to_s }.uniq

            #puts keyword_file_category_ids
            
            msg = "Detecting needed keyword categories."
            logger.info(msg.green)

            file_category_ids.each do |file_cat_id|
                            
                # Look for the category id in existing keyword categories to check 
                # if the file category already has the keyword category we need (target keyword category) 
                unless keyword_file_category_ids.include?(file_cat_id.to_s)
                    obj = KeywordCategories.new(file_keyword_category_found.name, file_cat_id)
                    kwd_cat_obj = create_keyword_categories(obj, true).first
                    
                    unless kwd_cat_obj
                        msg = "Keyword category creation failed in #{__callee__} method."
                        logger.error(msg)
                        abort
                    end

                    existing_keyword_categories.push(kwd_cat_obj)
                else
                    msg = "Keyword category in category #{file_cat_id} already exists."
                    logger.warn(msg.yellow)
                end

            end

            # Get all file keywords associated with all the file categories found in the project
            query_ids = existing_keyword_categories.map { |item| item.id }.join(',')
            
            op.add_option('keyword_category_id', query_ids)
            op.add_option('limit', '0')

            msg = "Retrieving existing keywords"
            logger.info(msg.green)

            existing_keywords = get_keywords(op)

            op.clear
            
            # Get the file count and calculate number of requests needed based on specified batch_size
            msg = "Calulating batch size."
            logger.info(msg.green)

            if total_file_count % batch_size == 0
                iterations = total_file_count / batch_size
            else
                iterations = total_file_count / batch_size + 1  #we'll need one more iteration to grab remaining
            end

            # Set up loop controls
            # Create update loop using iteration limit and batch size
            iterations.times do |num|
                
                num += 1
                # More efficient than setting the offset and limit in the query
                # TO DO: Implement this in the other admin functions
                start_index = offset
                end_index   = offset + limit
                ids = file_ids[start_index...end_index].join(',')

                op.add_option('id', ids)
                op.add_option('limit','0')
                op.add_option('keywords','all')
                op.add_option('fields','all')
                # Get current batch of files => body length of response used to track total files updated
                msg = "Batch #{num} of #{iterations} => Retrieving files."
                logger.info(msg.green)

                files = get_files(op)

                op.clear

                #puts "File objects #{files.inspect}"
                keywords_to_create = []
                
                msg = "Batch #{num} of #{iterations} => Extracting Keywords from fields."
                logger.info(msg.green)

                # Iterate through the files and find the keywords that need to be created
                files.each do |file|
                    #puts "In files create keywords from field before using instance_variable_get 1"
                    field_data      = nil
                    field_obj_found = nil

                    # Check if the field has any data in it
                    if built_in
                        field_name = source_field_found.name.downcase.gsub(' ','_')
                        #puts "Field name 1 : #{field_name}"
                        field_data = file.instance_variable_get("@#{field_name}")
                        field_data = field_data.strip
                        next if field_data.nil? || field_data == ''
                    else
                        field_obj_found = file.fields.find { |f| f.id == source_field_found.id }
                        if field_obj_found.nil? || field_obj_found.values.first.nil? || field_obj_found.values.first.strip == ''
                            next
                        end
                        field_data = field_obj_found.values.first
                    end

                    # Establish link between keyword and current file
                    associated_kwd_cat = existing_keyword_categories.find do |obj|
                        obj.name.downcase == file_keyword_category_found.name.downcase && 
                        obj.category_id.to_s == file.category_id.to_s 
                    end

                    unless associated_kwd_cat
                        msg = "Unable to retrieve associated keyword category!"
                        logger.fatal(msg)
                        abort
                    end

                    # split the string using the specified separator and remove empty strings
                    keywords_to_append = field_data.split(field_separator).reject { |val| val.to_s.strip.empty? }

                    keywords_to_append.each do |val|
                        val = val.gsub(/[\n\s]+/,' ').gsub("\u00A9",'(c)').encode("iso-8859-1", invalid: :replace, undef: :replace)
                        # Check if the value exists in existing keywords
                        keyword_found_in_existing = existing_keywords.find do |k|

                            begin
                                # In case we get an invalid input string like "\xA9" => copyright binary representation
                                # The downcase method can choke on this depending on the platform
                                # It works in windows but chokes in linux and possibly mac OS
                                k.name.downcase == val.downcase && k.keyword_category_id == associated_kwd_cat.id
                            rescue
                                k.name == val && k.keyword_category_id == associated_kwd_cat.id
                            end

                        end

                        if !keyword_found_in_existing
                            # find keyword cat id matching the category id of current file to establish the association
                            #puts "KEYWORD CATEGORIES "
                            #pp existing_keyword_categories
                            obj = existing_keyword_categories.find do |item| 
                                item.category_id.to_s == file.category_id.to_s && 
                                item.name.downcase == file_keyword_category_found.name.downcase
                            end
                            #puts "Existing keyword categories object"
                            #pp obj
                            # Insert into keywords_to_create array
                            keywords_to_create.push(Keywords.new(obj.id, val))

                        end
                        
                    end
                end

                # Remove duplicate keywords in the same keyword category and create them
                unless keywords_to_create.empty?
                    payload = keywords_to_create.uniq { |item| [item.name, item.keyword_category_id] }
                    
                    # Create the keywords for the current batch and set the generate objects flag to true.
                    puts "[INFO] Batch #{num} of #{iterations} => Creating Keywords."
                    new_keywords = create_keywords(payload, true)

                    # Append the returned keyword objects to the existing keywords array
                    if new_keywords
                        if new_keywords.is_a?(Array) && !new_keywords.empty?     
                            new_keywords.each do |item| 
                                existing_keywords.push(item) unless item.is_a?(Error)
                            end
                        else
                            msg = "An error occured creating keywords in #{__callee__}"
                            logger.error(msg)
                            abort
                        end
                    end
                end
                
                # Loop though the files again and tag them with the newly created keywords.
                # This is faster than making individual requests
                msg = "Batch #{num} of #{iterations} => Tagging files."
                logger.info(msg.green)

                files.each do | file |
                    #puts "In files tag before using instance_variable_get 2"
                    field_data      = nil
                    field_obj_found = nil
                    file.caption.to_s.gsub!(/\n+/,' ') # Prevents 400 error caused by newlines in caption field
                    file.original_filename = nil # Prevents 400 error when the filename extension and 
                                                 # original filename extension don't match.
                    # Look for the field and check if the field has any data in it
                    if built_in
                        field_name = source_field_found.name.downcase.gsub(' ','_')
                        #puts "Field name: #{field_name}"
                        field_data = file.instance_variable_get("@#{field_name}")
                        field_data = field_data.strip
                        #puts "Field value: #{field_data}"
                        next if field_data.nil? || field_data == ''
                    else
                        field_obj_found = file.fields.find { |f| f.id.to_s == source_field_found.id.to_s }
                        if field_obj_found.nil? || field_obj_found.values.first.nil? || field_obj_found.values.first.strip == ''
                            next
                        end
                        field_data = field_obj_found.values.first
                    end

                    if field_data
                        
                        # Remove empty strings
                        keywords = field_data.split(field_separator).reject { |val| val.to_s.strip.empty? }


                        # ESTABLISH LINK BETWEEN FILE AND KEYWORD
                        associated_kwd_cat = existing_keyword_categories.find do |item|
                            item.name.downcase == file_keyword_category_found.name.downcase &&
                            item.category_id.to_s == file.category_id.to_s
                        end

                        unless associated_kwd_cat
                            msg = "Existing keyword category retrieval failure in #{__callee__}"
                            logger.fatal(msg)
                            abort
                        end

                        # Loop through the keywords and tag the file
                        keywords.each do |value|
                            # Trim leading/trailing/mutltiple whitespaces and remove newlines
                            value = value.strip.gsub(/[\n\s]+/,' ').gsub("\u00A9",'(c)').encode("iso-8859-1", invalid: :replace, undef: :replace)

                            # Find the string in existing keywords
                            keyword_obj = existing_keywords.find do |item| 
                                begin
                                    item.name.downcase == value.downcase && associated_kwd_cat.id.to_s == item.keyword_category_id.to_s
                                rescue
                                    item.name == value && 
                                    associated_kwd_cat.id.to_s == item.keyword_category_id.to_s
                                end

                            end

                            if keyword_obj
                                # check if current file is already tagged
                                already_tagged = file.keywords.find { |item| item.to_s == keyword_obj.id.to_s }
                                # Tag the file
                                file.keywords.push(NestedKeywordItems.new(keyword_obj.id)) unless already_tagged
                            else
                                msg = "Unable to retrieve previously created keyword! => #{value.inspect} in #{__callee__}"
                                logger.fatal(msg)
                                abort
                            end
                            
                        end
                        
                    end
                end

                msg = "Batch #{num} of #{iterations} => Attempting to perform file updates."
                logger.info(msg.white)

                # Update files
                updated_obj_count = run_smart_update(files,total_files_updated)

                total_files_updated += updated_obj_count

                offset += limit
            end  
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

            project_ids                    = nil
            project_field_found            = nil
            built_in                       = nil
            project_keyword_category_found = nil
            projects                       = []
            existing_project_keywords      = []
            total_project_count            = 0
            iterations                     = 0
            offset                         = 0
            total_projects_updated         = 0
            batch_size                     = batch_size.to_i.abs
            limit                          = batch_size
            op                             = RestOptions.new

            # Validate input:
            
            # Retrieve project keyword category
            if target_project_keyword_category.is_a?(ProjectKeywordCategories) &&  # Object
            !target_project_keyword_category.id.nil?

            op.add_option('id',target_project_keyword_category.id)
            project_keyword_category_found = get_project_keyword_categories(op).first

            elsif (target_project_keyword_category.is_a?(String) && target_project_keyword_category.to_i > 0) ||  # Id
                  (target_project_keyword_category.is_a?(Integer) && !target_project_keyword_category.zero?)

                op.add_option('id',target_project_keyword_category)
                project_keyword_category_found = get_project_keyword_categories(op).first

            elsif target_project_keyword_category.is_a?(String) # Name

                op.add_option('name',target_project_keyword_category)
                op.add_option('textMatching','exact')
                project_keyword_category_found = get_project_keyword_categories(op)

                unless project_keyword_category_found
                    msg = "Project keyword category with name #{target_project_keyword_category.inspect} not found in OpenAsset."
                    logger.error(msg)
                    abort
                end

                if project_keyword_category_found.length > 1
                    msg = "Error: Multiple Project keyword categories found with search query #{op.get_options.inspect}." +
                          " Specify an id instead."
                    logger.error(msg)
                    abort
                else
                    project_keyword_category_found = project_keyword_category_found.first
                end

            else
                msg = "Argument Error: Expected one of the following: " +
                      "\n    1. Valid project keyword category object." +
                      "\n    2. Project keyword category id." +
                      "\n    3. Project keyword category name." +
                      "\nfor first argument in #{__callee__} method." +
                      "\nInstead got #{target_project_keyword_category.inspect}."
                logger.error(msg)
                abort
            end

            # Make sure it's a project keyword catgory
            unless project_keyword_category_found.is_a?(ProjectKeywordCategories)
                msg = "Error: Specified Project keyword category named #{project_keyword_category_found.name.inspect} with id " +
                      "#{project_keyword_category_found.id.inspect} is actually a #{project_keyword_category_found.class.inspect}."
                logger.error(msg)
                abort
            end

            op.clear

            # Retrieve project field
            if project_field.is_a?(Fields) && !project_field.id.nil?# Object

                op.add_option('id',project_field.id)
                project_field_found = get_fields(op).first

                unless project_field_found
                    msg = "Field with id #{project_field.id.inspect} not found in OpenAsset."
                    logger.error(msg)
                    abort
                end

            elsif (project_field.is_a?(String) && !project_field.to_i.zero?) ||  # Id
                (project_field.is_a?(Integer) && !project_field.zero?)

                op.add_option('id',project_field)
                project_field_found = get_fields(op).first

                unless project_field_found
                    msg = "Field with id #{project_field.inspect} not found in OpenAsset."
                    logger.error(msg)
                    abort
                end

            elsif project_field.is_a?(String) # Name

                op.add_option('name',project_field)
                op.add_option('textMatching','exact')
                project_field_found = get_fields(op)

                if project_field_found.empty?
                    msg = "Field with name #{project_field.inspect} not found in OpenAsset."
                    logger.error(msg)
                    abort
                end

                if project_field_found.length > 1
                    msg = "Error: Multiple fields found with name #{project_field.inspect}. Specify an id instead."
                    logger.error(msg)
                    abort
                else
                    project_field_found = project_field_found.first
                end
            else 
                msg = "Error: Expected one of the following: " +
                      "\n    1. Valid Fields object." +
                      "\n    2. Field id." +
                      "\n    3. Field name." +
                      "\nfor second argument in #{__callee__} method." +
                      "\nInstead got #{project_field.inspect}."
                logger.error(msg)
                abort
            end

            # Make sure it's a project field
            unless project_field_found.field_type == 'project'
                msg = "Error: Specified field #{project_field_found.name.inspect} with id " +
                      "#{project_field_found.id.inspect} is not a project field"
                logger.error(msg)
                abort
            end

            built_in = (project_field_found.built_in == '1') ? true : false 

            if field_separator.nil?
                msg = "You Must specify field separator."
                logger.error(msg)
                abort
            end

            if batch_size.zero?
                msg = "Invalid batch size. Specify a positive numeric value or use default value of 200."
                logger.error(msg)
                abort
            end

            op.clear

            # Get projects keywords
            msg = "Retrieving project keywords."
            logger.info(msg.green)

            op.add_option('limit','0')
            op.add_option('project_keyword_category_id',project_keyword_category_found.id)

            existing_project_keywords = get_project_keywords(op)
            
            op.clear

            op.add_option('limit','0')
            op.add_option('displayFields','id')

            project_ids = get_projects(op).map { |obj| obj.id.to_s }

            if project_ids.length.zero?
                msg = "No Projects found in OpenAsset!"
                logger.error(msg)
                abort
            end

            op.clear

            total_project_count = project_ids.length

            # Set up iterations loop
            msg = "Calculating batch size"
            logger.info(msg.green)

            if total_project_count % batch_size == 0
                iterations = total_project_count / batch_size
            else
                iterations = total_project_count / batch_size + 1 # To grab remaining
            end

            iterations.times do |num|

                num += 1

                start_index = offset
                end_index   = offset + limit
                ids         = project_ids[start_index...end_index].join(',')

                op.add_option('limit','0')
                op.add_option('id',ids)
                op.add_option('projectKeywords','all')
                op.add_option('fields','all')

                msg = "Batch #{num} of #{iterations} => Retrieving projects."
                logger.info(msg.green)

                projects = get_projects(op)

                op.clear

                if projects.empty?
                    msg = "Project retrieval failure in #{__callee__} method."
                    logger.fatal(msg)
                    abort
                end

                keywords_to_create = []
                
                msg = "Batch #{num} of #{iterations} => Extracting Keywords from field."
                logger.info(msg.green)

                # Iterate through the projects and find the project keywords that need to be created
                projects.each do |project|
                    #puts "In files create keywords from field before using instance_variable_get 1"
                    field_data      = nil
                    field_obj_found = nil

                    # Check if the field has any data in it
                    if built_in
                        field_name = project_field_found.name.downcase.gsub(' ','_')
                        #puts "Field name 1 : #{field_name}"
                        field_data = project.instance_variable_get("@#{field_name}")
                        field_data = field_data.strip
                        next if field_data.nil? || field_data == ''
                    else
                        field_obj_found = project.fields.find { |f| f.id == project_field_found.id }
                       
                        if field_obj_found.nil? || field_obj_found.values.first.nil? || field_obj_found.values.first.strip == ''
                            next
                        end
                       
                        field_data = field_obj_found.values.first
                        
                    end

                    # split the string using the specified separator and remove empty strings
                    project_keywords_to_append = field_data.split(field_separator).reject { |val| val.to_s.strip.empty? }

                    project_keywords_to_append.each do |val|
                        
                        val = val.strip.gsub(/[\n\s]+/,' ').gsub("\u00A9",'(c)').encode("iso-8859-1", invalid: :replace, undef: :replace)
                        # Check if the value exists in existing keywords
                        keyword = existing_project_keywords.find do |k|

                            begin
                                # In case we get an invalid input string like "\xA9" => copyright binary representation
                                # The downcase method can choke on this depending on the platform
                                # It works in windows but chokes in linux and possibly mac OS
                                k.name.downcase == val.downcase 
                            rescue
                                k.name == val 
                            end

                        end

                        unless keyword
                            # Insert into keywords_to_create array
                            keywords_to_create.push(ProjectKeywords.new(val,project_keyword_category_found.id))
                        end
                        
                    end
                end

                # Remove entries with the same name then create new keywords
                unless keywords_to_create.empty?

                    payload = keywords_to_create.uniq { |item| item.name }
                    
                    # Create the project keywords for the current batch and set the generate objects flag to true.
                    msg = "Batch #{num} of #{iterations} => Creating Project Keywords."
                    logger.info(msg.green)

                    new_keywords = create_project_keywords(payload, true)

                    # Append the returned project keyword objects to the existing keywords array
                    if new_keywords    
                        new_keywords.each do |item| 
                            existing_project_keywords.push(item) unless item.is_a?(Error)
                        end
                    end
                
                end
                
                # Loop though the projects again and tag them with the newly created project keywords.
                # This is faster than making individual requests
                msg = "Batch #{num} of #{iterations} => Tagging Projects."
                logger.info(msg.green)

                projects.each do |project|
                    
                    field_data      = nil
                    field_obj_found = nil

                    # Look for the field and check if the field has any data in it
                    if built_in
                        field_name = project_field_found.name.downcase.gsub(' ','_')
                        #puts "Field name: #{field_name}"
                        field_data = project.instance_variable_get("@#{field_name}")
                        field_data = field_data.strip
                        #puts "Field value: #{field_data}"
                        next if field_data.nil? || field_data == ''
                    else
                        field_obj_found = project.fields.find { |f| f.id.to_s == project_field_found.id.to_s }
                        if field_obj_found.nil? || field_obj_found.values.first.nil? || field_obj_found.values.first.strip == ''
                            next
                        end
                        field_data = field_obj_found.values.first
                    end

                    # Remove empty strings
                    keywords = field_data.split(field_separator).reject { |val| val.to_s.strip.empty? }

                    # Loop through the keywords and tag the file
                    keywords.each do |value|
                        # Trim leading & trailing whitespace
                        value = value.strip.gsub(/[\n\s]+/,' ').gsub("\u00A9",'(c)').encode("iso-8859-1", invalid: :replace, undef: :replace)
                        # Find the string in existing keywords
                        proj_keyword_obj = existing_project_keywords.find do |item| 
                            begin
                                item.name.downcase == value.downcase
                            rescue
                                item.name == value
                            end

                        end

                        if proj_keyword_obj
                            # check if current file is already tagged
                            already_tagged = project.project_keywords.find { |item| item.id.to_s == proj_keyword_obj.id.to_s }
                            # Tag the project
                            msg = "Tagging project #{project.code.inspect} with => #{value.inspect}."
                            logger.info(msg.green)

                            project.project_keywords.push(NestedProjectKeywordItems.new(proj_keyword_obj.id)) unless already_tagged
                        else
                            msg = "Unable to retrieve previously created keyword! => #{value.inspect} in #{__callee__}"
                            logger.fatal(msg)
                            abort
                        end
                        
                    end
                        
                end

                # Update projects
                msg = "Batch #{num} of #{iterations} => Attempting to perform project updates."
                logger.info(msg.green)

                updated_obj_count = run_smart_update(projects,total_projects_updated)

                total_projects_updated += updated_obj_count

                offset += limit

            end            

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

            project_ids                    = nil
            projects                       = nil
            project_field_found            = nil
            project_keyword_category_found = nil
            project_keywords               = nil
            total_project_count            = 0
            iterations                     = 0
            offset                         = 0
            total_projects_updated         = 0
            batch_size                     = batch_size.to_i.abs
            limit                          = batch_size
            op                             = RestOptions.new

            # Validate input:
            
            # Retrieve project keyword category
            if source_project_keyword_category.is_a?(ProjectKeywordCategories) &&  # Object
                !source_project_keyword_category.id.nil?
    
                op.add_option('id',source_project_keyword_category.id)
                project_keyword_category_found = get_project_keyword_categories(op).first
    
            elsif (source_project_keyword_category.is_a?(String) && source_project_keyword_category.to_i > 0) ||  # Id
                    (source_project_keyword_category.is_a?(Integer) && !source_project_keyword_category.zero?)

                op.add_option('id',source_project_keyword_category)
                project_keyword_category_found = get_project_keyword_categories(op).first

            elsif source_project_keyword_category.is_a?(String) # Name

                op.add_option('name',source_project_keyword_category)
                op.add_option('textMatching','exact')
                project_keyword_category_found = get_project_keyword_categories(op)

                unless project_keyword_category_found
                    msg = "Project keyword category with name #{target_project_keyword_category.inspect} not found in OpenAsset."
                    logger.error(msg)
                    abort
                end

                if project_keyword_category_found.length > 1
                    msg = "Multiple Project keyword categories found with search query #{op.get_options.inspect}." +
                          " Specify an id instead."
                    logger.error(msg)    
                    abort
                else
                    project_keyword_category_found = project_keyword_category_found.first
                end

            else
                msg = "Argument Error: Expected one of the following: " +
                      "\n    1. Valid project keyword category object." +
                      "\n    2. Project keyword category id." +
                      "\n    3. Project keyword category name." +
                      "\nfor first argument in #{__callee__} method." +
                      "\nInstead got #{target_project_keyword_category.inspect}."
                logger.error(msg)
                abort
            end

            # Make sure it's a project keyword catgory
            unless project_keyword_category_found.is_a?(ProjectKeywordCategories)
                msg = "Error: Specified Project keyword category named #{project_keyword_category_found.name.inspect} with id " +
                      "#{project_keyword_category_found.id.inspect} is actually a #{project_keyword_category_found.class.inspect}."
                logger.error(msg)
                abort
            end

            op.clear

            # Retrieve project field
            if target_project_field.is_a?(Fields) && !target_project_field.id.nil?# Object

                op.add_option('id',target_project_field.id)
                project_field_found = get_fields(op).first

                unless project_field_found
                    msg = "Field with id #{project_field.id.inspect} not found in OpenAsset."
                    logger.error(msg)
                    abort
                end

            elsif (target_project_field.is_a?(String) && !target_project_field.to_i.zero?) ||  # Id
                  (target_project_field.is_a?(Integer) && !target_project_field.zero?)

                op.add_option('id',target_project_field)
                project_field_found = get_fields(op).first

                unless project_field_found
                    msg = "Field with id #{target_project_field.inspect} not found in OpenAsset."
                    logger.error(msg)
                    abort
                end

            elsif target_project_field.is_a?(String) # Field Name

                op.add_option('name',target_project_field)
                op.add_option('textMatching','exact')
                project_field_found = get_fields(op)

                if project_field_found.empty?
                    msg = "Field with name #{target_project_field.inspect} not found in OpenAsset."
                    logger.error(msg)
                    abort
                end

                if project_field_found.length > 1
                    msg = "Multiple fields found with name #{target_project_field.inspect}. Specify an id instead."
                    logger.error(msg)
                    abort
                else
                    project_field_found = project_field_found.first
                end
            else 
                msg = "Error: Expected one of the following: " +
                      "\n    1. Valid Fields object." +
                      "\n    2. Field id." +
                      "\n    3. Field name." +
                      "\nfor second argument in #{__callee__} method." +
                      "\nInstead got #{target_project_field.inspect}."
                logger.error(msg)
                abort
            end

            # Make sure it's a project field
            unless project_field_found.field_type == 'project'
                msg = "Error: Specified field #{project_field_found.name.inspect} with id " +
                      "#{project_field_found.id.inspect} is not a project field."
                logger.error(msg)
                abort
            end
            
            if RESTRICTED_LIST_FIELD_TYPES.include?(project_field_found.field_display_type)
                answer = nil
                error  = "\nInvalid input. Please enter \"yes\" or \"no\".\n> "
                message = "Warning: You are inserting keywords into a restricted field type. " +
                          "\n     Project keywords are sorted in alphabetical order. " +
                          "\n     All project keywords will be created as options but only the first one will be displayed in the field." +
                          "\nContinue? (Yes/no)\n> "

                print message.yellow

                while answer != 'yes' && answer != 'no'

                    print error unless answer.nil?

                    answer = gets.chomp.to_s.downcase

                    abort("You entered #{answer.inspect}. Exiting.\n\n") if answer.downcase == 'no' || answer == 'n'

                    break if answer == 'yes' || answer == 'y'

                end          
            
            end

            if field_separator.nil?
                msg = "You must specify a field separator."
                logger.error(msg)
                abort
            end

            unless ['append','overwrite'].include?(insert_mode.to_s)
                msg = "Error: Expected \"append\" or \"overwrite\" for fourth argument \"insert_mode\" in #{__callee__}. " +
                      "Instead got #{insert_mode.inspect}"
                logger.error(msg)
                abort
            end

            if batch_size.zero?
                msg = "Invalid batch size. Specify a positive numeric value or use default value of 200."
                logger.error(msg)
                abort
            end

            op.clear

            # Get projects keywords
            op.add_option('limit','0')
            op.add_option('project_keyword_category_id',project_keyword_category_found.id)

            project_keywords = get_project_keywords(op)

            op.clear

            # Get projects
            op.add_option('limit','0')
            op.add_option('displayFields','id')

            project_ids = get_projects(op).map { |obj| obj.id.to_s }

            if project_ids.length.zero?
                msg = "No Projects found in OpenAsset!"
                logger.error(msg)
                abort
            end

            op.clear

            total_project_count = project_ids.length

            # Set up iterations loop
            if total_project_count % batch_size == 0
                iterations = total_project_count / batch_size
            else
                iterations = total_project_count / batch_size + 1 # To grab remaining
            end

            iterations.times do |num|

                num += 1

                start_index = offset
                end_index   = offset + limit
                ids         = project_ids[start_index...end_index].join(',')

                op.add_option('limit','0')
                op.add_option('id',ids)

                msg = "Batch #{num} of #{iterations} => Retrieving projects."
                logger.info(msg.green)

                projects = get_projects(op)

                op.clear

                # Move project keywords to field
                msg = "Batch #{num} of #{iterations} => Extacting project keywords."
                logger.info(msg.green)

                processed_projects = move_keywords_to_fields(projects,
                                                             project_keywords,
                                                             project_field_found,
                                                             field_separator,
                                                             insert_mode)

                # Update projects
                msg = "Batch #{num} of #{iterations} => Attempting to perform project updates."
                logger.info(msg.green)

                updated_obj_count = run_smart_update(processed_projects,total_projects_updated)

                total_projects_updated += updated_obj_count

                offset += limit

            end            

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
        #          rest_client.move_file_keywords_to_field_by_album("album name","keyword category name","project field name",';','append',250)
        #          rest_client.move_file_keywords_to_field_by_album("album name","keyword category name","project field name",';','overwrite',250)
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

            # Validate input
            args = process_field_to_keyword_move_args('albums',
                                                       album,
                                                       keyword_category,
                                                       target_field,
                                                       field_separator,
                                                       batch_size,
                                                       true)

            
            
            file_keyword_categories_found = 
                (args.target_keyword_category.is_a?(Array)) ? args.target_keyword_category : [args.target_keyword_category]

            target_field_found            = args.source_field
            album_found                   = args.container

            file_ids                      = nil
            file_keyword_ids              = []
            file_keyword_category_ids     = []
            keywords                      = []
            files                         = []
            processed_files               = []
            total_file_count              = 0
            total_files_updated           = 0  # For better readability
            offset                        = 0
            iterations                    = 0
            limit                         = batch_size.to_i.abs 
            op                            = RestOptions.new

            # Validate insert mode and warn user of restricted field type
            if RESTRICTED_LIST_FIELD_TYPES.include?(target_field_found.field_display_type)
                answer = nil
                error  = "\nInvalid input. Please enter \"yes\" or \"no\".\n> "
                message = "Warning: You are inserting keywords into a restricted field type. " +
                          "\n     Project keywords are sorted in alphabetical order. " +
                          "\n     All file keywords will be created as options but only the first one will be displayed in the field." +
                          "\nContinue? (Yes/no)\n> "

                print message

                while answer != 'yes' && answer != 'no'

                    print error unless answer.nil?

                    answer = gets.chomp.to_s.downcase

                    abort("You entered #{answer.inspect}. Exiting.\n\n") if answer.downcase == 'no' || answer == 'n'

                    break if answer == 'yes' || answer == 'y'

                end          
            
            end

            unless ['append','overwrite'].include?(insert_mode.to_s)
                msg = "Argument Error: Expected \"append\" or \"overwrite\" for fourth argument \"insert_mode\" in #{__callee__}. " +
                      "Instead got #{insert_mode.inspect}"
                logger.error(msg)
                abort
            end
            
            # Get keywords
            msg = "Retrieving keywords for keyword category => #{file_keyword_categories_found.first.name.inspect}."
            logger.info(msg.green)
            
            file_keyword_category_ids = file_keyword_categories_found.map(&:id)

            op.add_option('limit','0')
            op.add_option('keyword_category_id',file_keyword_category_ids.join(','))

            keywords = get_keywords(op)

            if keywords.empty?
                msg = "No keywords found in keyword category => #{file_keyword_category_found.name.inspect} " +
                      "with id #{file_keyword_category_found.id.inspect}"
                logger.error(msg)
                abort
            end

            file_keyword_ids = keywords.map(&:id)

            op.clear

            # Get file ids
            msg = "Retrieving file ids in album #{album_found.name.inspect}."
            logger.info(msg.green)

            file_ids = album_found.files.map { |obj| obj.id.to_s }

            msg = "Calculating batch size."
            logger.info(msg.green)

            total_file_count = file_ids.length

            if total_file_count.zero?
                msg = "No files found in album #{album_found.name.inspect} with id #{album_found.id.inspect}."
                logger.error(msg)
                abort
            end

            # Set up iterations loop
            if total_file_count % batch_size == 0
                iterations = total_file_count / batch_size
            else
                iterations = total_file_count / batch_size + 1 # To grab remaining
            end

            iterations.times do |num|

                num += 1

                # Get file batch
                start_index = offset
                end_index   = offset + limit
                ids         = file_ids[start_index...end_index].join(',')

                msg = "Batch #{num} of #{iterations} => Retrieving files."
                logger.info(msg.green)

                op.add_option('limit','0')
                op.add_option('id',ids)

                files = get_files(op)

                # Move the keywords
                processed_files = move_keywords_to_fields(files,keywords,target_field_found,field_separator,insert_mode)

                # Perform file update
                msg = "Batch #{num} of #{iterations} => Attempting to perform file updates."
                logger.info(msg.white)

                updated_obj_count = run_smart_update(processed_files,total_files_updated)

                total_files_updated += updated_obj_count

                offset += limit

            end
            
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
        #          rest_client.move_file_keywords_to_field_by_project("project name","keyword category name","project field name",';','append',250)
        #          rest_client.move_file_keywords_to_field_by_project("project name","keyword category name","project field name",';','overwrite',250)
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
            # Validate input
            args = process_field_to_keyword_move_args('projects',
                                                      project,
                                                      keyword_category,
                                                      target_field,
                                                      field_separator,
                                                      batch_size,
                                                      true)

            file_keyword_categories_found = 
                (args.target_keyword_category.is_a?(Array)) ? args.target_keyword_category : [args.target_keyword_category]
            project_found                 = args.container
            target_field_found            = args.source_field

            file_keyword_category_ids     = nil
            built_in                      = nil
            file_ids                      = nil
            keywords                      = []
            files                         = []
            total_file_count              = 0
            total_files_updated           = 0  # For better readability
            offset                        = 0
            iterations                    = 0
            limit                         = batch_size.to_i.abs
            op                            = RestOptions.new

            # Validate insert mode and warn user of restricted field type
            if RESTRICTED_LIST_FIELD_TYPES.include?(target_field_found.field_display_type)
                answer = nil
                error  = "\nInvalid input. Please enter \"yes\" or \"no\".\n> "
                message = "Warning: You are inserting keywords into a restricted field type. " +
                          "\n     Project keywords are sorted in alphabetical order. " +
                          "\n     All file keywords will be created as options but only the first one will be displayed in the field." +
                          "\nContinue? (Yes/no)\n> "

                print message

                while answer != 'yes' && answer != 'no'

                    print error unless answer.nil?

                    answer = gets.chomp.to_s.downcase

                    abort("You entered #{answer.inspect}. Exiting.\n\n") if answer.downcase == 'no' || answer == 'n'

                    break if answer == 'yes' || answer == 'y'

                end          
            
            end

            unless ['append','overwrite'].include?(insert_mode.to_s)
                msg = "Argument Error: Expected \"append\" or \"overwrite\" for fourth argument \"insert_mode\" in #{__callee__}. " +
                      "Instead got #{insert_mode.inspect}"
                logger.error(msg)
                abort
            end

            # Check the source_field field type
            built_in = (target_field_found.built_in == '1') ? true : false

            # Get keywords
            msg = "Retrieving keywords for keyword category => #{file_keyword_categories_found.first.name.inspect}."
            logger.info(msg.green)

            file_keyword_category_ids = file_keyword_categories_found.map(&:id).join(',')
            op.add_option('limit','0')
            op.add_option('keyword_category_id',file_keyword_category_ids)

            keywords = get_keywords(op)

            if keywords.empty?
                msg = "No keywords found in keyword category => #{file_keyword_categories_found.first.name.inspect}."
                logger.error(msg)            
                abort
            end

            op.clear
            
            # Get file ids
            msg = "Retrieving file ids in project => #{project_found.name.inspect}."
            logger.info(msg.green)
            
            op.add_option('limit','0')
            op.add_option('displayFields','id')
            op.add_option('project_id',"#{project_found.id}") # Returns files in specified project

            files = get_files(op)

            op.clear

            if files.empty?
                msg = "Project #{project_found.name.inspect} with id #{project_found.id.inspect} is empty."
                logger.error(msg)
                abort
            end

            # Extract file ids
            file_ids = files.map { |obj| obj.id.to_s }

            # Prep iterations loop
            total_file_count = file_ids.length

            msg = "Calculating batch size."
            logger.info(msg.green)

            if total_file_count % batch_size == 0
                iterations = total_file_count / batch_size
            else
                iterations = total_file_count / batch_size + 1
            end

            iterations.times do |num|

                num += 1

                start_index = offset
                end_index   = limit
                ids         = file_ids[start_index...end_index].join(',')

                msg = "Batch #{num} of #{iterations} => Retrieving files."
                logger.info(msg.green)

                op.add_option('limit','0')
                op.add_option('id',ids)

                # Get current batch of files
                files = get_files(op)

                # Move the file keywords to specified field
                move_keywords_to_fields(files,keywords,target_field_found,field_separator,insert_mode)

                # Perform file update
                msg = "Batch #{num} of #{iterations} => Attempting to perform file updates."
                logger.info(msg.white)

                updated_obj_count = run_smart_update(files,total_files_updated)

                total_files_updated += updated_obj_count

                offset += limit
            end

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
        #          rest_client.move_file_keywords_to_field_by_category("category name","keyword category name","project field name",';','append',250)
        #          rest_client.move_file_keywords_to_field_by_category("category name","keyword category name","project field name",';','overwrite',250)
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

            # Validate input
            args = process_field_to_keyword_move_args('categories',
                                                      category,
                                                      keyword_category,
                                                      target_field,
                                                      field_separator,
                                                      batch_size,
                                                      false)

            category_found              = args.container
            file_keyword_category_found = args.target_keyword_category
            target_field_found          = args.source_field

            built_in                    = nil
            file_ids                    = nil
            keywords                    = []
            files                       = []
            total_file_count            = 0
            total_files_updated         = 0  # For better readability
            offset                      = 0
            iterations                  = 0
            limit                       = batch_size.to_i.abs
            op                          = RestOptions.new

            # Validate insert mode and warn user of restricted field type
            if RESTRICTED_LIST_FIELD_TYPES.include?(target_field_found.field_display_type)
                answer = nil
                error  = "\nInvalid input. Please enter \"yes\" or \"no\".\n> "
                message = "Warning: You are inserting keywords into a restricted field type. " +
                          "\n     Project keywords are sorted in alphabetical order. " +
                          "\n     All file keywords will be created as options but only the first one will be displayed in the field." +
                          "\nContinue? (Yes/no)\n> "

                print message

                while answer != 'yes' && answer != 'no'

                    print error unless answer.nil?

                    answer = gets.chomp.to_s.downcase

                    abort("You entered #{answer.inspect}. Exiting.\n\n") if answer.downcase == 'no' || answer == 'n'

                    break if answer == 'yes' || answer == 'y'

                end          
            
            end

            unless ['append','overwrite'].include?(insert_mode.to_s)
                msg = "Argument Error: Expected \"append\" or \"overwrite\" for fourth argument \"insert_mode\" in #{__callee__}. " +
                      "Instead got #{insert_mode.inspect}"
                logger.error(msg)
                abort
            end

            # Check the source_field field type
            built_in = (target_field_found.built_in == '1') ? true : false

            # Get keywords
            msg = "Retrieving keywords for keyword category => #{file_keyword_category_found.name.inspect}."
            logger.info(msg.green)

            op.add_option('limit','0')
            op.add_option('keyword_category_id',"#{file_keyword_category_found.id}")

            keywords = get_keywords(op)

            if keywords.empty?
                msg = "No keywords found in keyword category => #{file_keyword_category_found.name.inspect} " +
                      "with id #{file_keyword_category_found.id.inspect}"
                logger.error(msg)
                abort
            end

            op.clear
            
            # Get file ids
            msg = "Retrieving file ids in category => #{category_found.name.inspect}."
            logger.info(msg.green)

            op.add_option('limit','0')
            op.add_option('displayFields','id')
            op.add_option('category_id',"#{category_found.id}") # Returns files in specified project

            files = get_files(op)

            op.clear

            if files.empty?
                msg = "Category #{category_found.name.inspect} with id #{category_found.id.inspect} is empty."
                logger.error(msg)
                abort
            end

            # Extract file ids
            file_ids = files.map { |obj| obj.id.to_s }

            # Prep iterations loop
            total_file_count = file_ids.length

            msg = "Calculating batch size."
            logger.info(msg.green)

            if total_file_count % batch_size == 0
                iterations = total_file_count / batch_size
            else
                iterations = total_file_count / batch_size + 1
            end

            iterations.times do |num|

                num += 1

                start_index = offset
                end_index   = limit
                ids         = file_ids[start_index...end_index].join(',')

                msg = "Batch #{num} of #{iterations} => Retrieving files."
                logger.info(msg.green)

                op.add_option('limit','0')
                op.add_option('id',ids)

                # Get current batch of files
                files = get_files(op)

                # Move the file keywords to specified field
                move_keywords_to_fields(files,keywords,target_field_found,field_separator,insert_mode)

                # Perform file update
                msg = "Batch #{num} of #{iterations} => Attempting to perform file updates."
                logger.info(msg.white)
                
                updated_obj_count = run_smart_update(files,total_files_updated)

                total_files_updated += updated_obj_count

                offset += limit
            end
            
        end
    end

end

