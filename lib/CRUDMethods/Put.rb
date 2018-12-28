require_relative '../Constants.rb'
require_relative './Request.rb'

module Put

    include Request
    # @!visibility private
    def put(uri,data,generate_objects=false)

        resource = uri.to_s.split('/').last

        options = {
            :request_type => 'PUT',
            :uri => uri,
            :data => data
        }
        response = send_request(options)

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