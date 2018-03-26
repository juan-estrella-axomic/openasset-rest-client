module ConnectionTester
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

end