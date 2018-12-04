module Put
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
end