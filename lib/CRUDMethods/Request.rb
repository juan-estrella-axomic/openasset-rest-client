require_relative '../Constants.rb'
require_relative '../MyLogger.rb'
require_relative '../Validator.rb'

module Request

    def send_request(options = {})
        request_type = options[:request_type].to_s.upcase
        uri          = options[:uri]
        rest_options = options[:rest_options]
        data         = options[:data]

        json_body = nil
        request   = nil
        response  = nil

        case request_type
        when 'GET'
            request = Net::HTTP::Get.new(uri.request_uri + rest_options.get_options)
        when 'POST'
            request = Net::HTTP::Post.new(uri.request_uri)
        when 'PUT'
            request = Net::HTTP::Put.new(uri.request_uri)
        when 'DELETE'
            request = Net::HTTP::Delete.new(uri.request_uri)
        else
            Logging.logger.error("Invalid request type #{request_type.inspect}")
            return
        end

        # Prep body data
        if request_type.eql?('POST') || request_type.eql?('PUT')
            json_body = Validator.validate_and_process_request_data(data)
        elsif request_type.eql?('DELETE')
            json_body = Validator.validate_and_process_delete_body(data)
        end

        # Don't make request with an empty body
        if !request_type.eql?('GET') && !json_body
            msg = "No data in json_body being sent for #{request_type} request."
            logger.error(msg)
            return false
        end

        # Handle 2048 character limit with GET requests
        if request_type.eql?('GET') && rest_options.get_options.length > 2048
            request = Net::HTTP::Post.new(uri.request_uri)
            request.add_field('X-Http-Method-Override','GET')
            form_data = generate_form_data(rest_options)
            request.set_form_data(form_data)
            request_type = 'POST' # Ensure new body is properly encoded below
        end

        # Encode body in UTF-8
        unless request_type.eql?('GET')
            request.body = encode_json_to_utf8(json_body,@outgoing_encoding,@incoming_encoding)
        end

        # Send the request and return the response
        begin
            attempts ||= 1
            @retry_limit.times do # Handle 502 and 503 errors
                response = Net::HTTP.start(uri.host, uri.port, :read_timeout => 300, :use_ssl => uri.scheme == 'https') do |http|
                    session = @session ? @session : @authenticator.get_session()
                    request.add_field('X-SessionKey',session)
                    http.request(request)
                end
                break if response.kind_of? Net::HTTPSuccess ||
                        !RECOVERABLE_NET_HTTP_EXCEPTIONS.include?(response.class)
                wait_and_try_again({:attempts => attempts})
                attempts += 1
            end
        rescue StandardError => e # Handle connection errors
            if attempts < @retry_limit
                wait_and_try_again({:attempts => attempts})
                attempts += 1
                retry
            end
            logger.error("Connection failed. The server is not responding. - #{e}")
            Thread.exit
        end
        response
    end

    ###########
    # HELPERS #
    ###########

    # @!visibility private
    def generate_form_data(rest_options)
        post_parameters = {}

        # Remove beginning ? mark from query
        options_str = rest_options.get_options.sub(/^\?/,'')

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
                    rescue JSON::ParserError => e
                        logger.error(e.message)
                        logger.error("Value causing the error => #{existing_data.inspect}")
                        Thread.exit
                    rescue StandardError => e
                        logger.error("Error => #{e.message}")
                        Thread.exit
                    end
                else
                    post_parameters[key] = existing_data + ',' + value  # For non array list format => ?id=1,2,3
                end
            else
                post_parameters[key] = value # For regular key value format => ?name=joe
            end
        end
        post_parameters
    end
end