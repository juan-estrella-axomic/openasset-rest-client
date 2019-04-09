require_relative '../SmartUpdater'
require_relative '../Constants.rb'
require_relative './Request.rb'

module Get
    include SmartUpdater
    include Request
    # @!visibility private
    def get(uri,rest_options,with_nested_resources=false)
        resource = uri.to_s.split('/').last
        rest_options ||= RestOptions.new
        json_body = []

        if with_nested_resources
        # Ensures File resource query returns all nested resources
            case resource
            when 'Files'
                rest_options.add_option('sizes','all')
                rest_options.add_option('keywords','all')
                rest_options.add_option('fields','all')
            when 'Albums'
                rest_options.add_option('files','all')
                rest_options.add_option('groups','all')
                rest_options.add_option('users','all')
            when 'Projects'
                rest_options.add_option('projectKeywords','all')
                rest_options.add_option('fields','all')
                rest_options.add_option('albums','all')
                rest_options.add_option('withLocation','1')
                rest_options.add_option('withHeroImage','1')
                rest_options.add_option('remoteFields','data_integration_id')
            when 'Fields'
                rest_options.add_option('fieldLookupStrings','all')
            when 'Searches'
                rest_options.add_option('groups','all')
                rest_options.add_option('users','all')
            when 'Groups'
                rest_options.add_option('users','all')
            when 'Users'
                rest_options.add_option('groups','all')
            else
            end

        end

        options = {
            :request_type => 'GET',
            :uri => uri,
            :rest_options => rest_options
        }
        response = send_request(options)

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
