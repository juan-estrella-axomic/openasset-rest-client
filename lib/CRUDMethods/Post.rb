require_relative '../Constants.rb'

module Post
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
            if attempts < MAX_REQUEST_RETRIES
                wait_and_try_again({:attempts => attempts})
                attempts += 1
                retry
            end
            logger.error("Connection failed. The server is not responding. - #{e}")
            Thread.exit
            #exit(-1)
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
end