require_relative '../SmartUpdater'
require_relative '../Constants.rb'
require_relative './Request.rb'
require_relative '../MyLogger.rb'

module Merge

    include SmartUpdater
    include Request
    # @!visibility private
    def merge(uri,target,source)

        resource = uri.to_s.split('/').last
        target   = target.first if target.is_a?(Array)
        target   = target.id if target.respond_to?(:id)
        source   = [data] unless data.is_a?(Array)

        unless target.to_i > 0
            logger.error("Invalid merge target id: (#{target}) - Aborting request")
            return
        end

        options = {
            :request_type => 'MERGE',
            :uri => uri + '/' + target, # Combine enpoint with target id
            :rest_options => {},
            :data => source
        }

        response = send_request(options)

        Validator.process_http_response(response,@verbose,resource,options[:request_type])

        return unless response.kind_of?(Net::HTTPSuccess)

        response.body.encode!(@outgoing_encoding,
                              @incoming_encoding,
                              invalid: :replace,
                              undef: :replace,
                              replace: '?') # Encode returned data into utf-8

        begin
            json_body = JSON.parse(response.body)
        rescue JSON::ParserError => e
            logger.error("Error parsing JSON: #{e.message}")
            return []
        end
        return generate_objects_from_json_response_body(json_body, resource)
    end
end
