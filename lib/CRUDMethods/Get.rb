module Get
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
                options.add_option('withLocation','1')
                options.add_option('withHeroImage','1')
            when 'Fields'
                options.add_option('fieldLookupStrings','all')
            when 'Searches'
                options.add_option('groups','all')
                options.add_option('users','all')
            when 'Groups'
                options.add_option('users','all')
            when 'Users'
                options.add_option('groups','all')
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
                    options_str = options.get_options.sub(/^\?/,'')

                    # Break down the string and extract key value arguments for the post parameters
                    key_value_pairs = options_str.split(/&/).map do |key_val|
                        #puts key_val
                        key_val.split(/=/)

                    end

                    key_value_pairs.each do |key, val|

                        key   = key.to_sym
                        value = nil

                        begin
                            value = URI.decode(val)
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
end