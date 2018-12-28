require_relative '../Constants.rb'
require_relative './Request.rb'

module Delete

    include Request
	# @!visibility private
    def delete(uri,data)

        resource  = uri.to_s.split('/').last

        options = {
            :request_type => 'DELETE',
            :uri => uri,
            :data => data
        }
        response = send_request(options)

        response = Validator.process_http_response(response,@verbose,resource,'DELETE')

        res = process_errors(data,response,resource,'Delete')

        return res   # Success should always return an empty array. Any content means there was an error,
    end
end