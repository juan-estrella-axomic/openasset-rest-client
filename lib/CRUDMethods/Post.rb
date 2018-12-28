require_relative '../Constants.rb'
require_relative './Request.rb'

module Post
    include Request
    # @!visibility private
    def post(uri,data,generate_objects=false)

        data = [data] unless data.is_a?(Array)
        resource = ''

        if uri.to_s.split('/').last.to_i == 0 #its a non numeric string meaning its a resource endpoint
            resource = uri.to_s.split('/').last
        else
            resource = uri.to_s.split('/')[-2] #the request is using a REST shortcut so we need to grab
        end                                       #second to last string of the url as the endpoint

        options = {
            :request_type => 'POST',
            :uri => uri,
            :data => data
        }
        response = send_request(options)

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