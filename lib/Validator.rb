require 'uri'
require 'colorize'
require 'json'

require_relative 'MyLogger'

class Validator

    NOUNS = %w[
                AccessLevels 
                Albums 
                AlternateStores 
                AspectRatios 
                Categories 
                CopyrightHolders 
                CopyrightPolicies
                FieldLookupStrings
                Fields 
                Files 
                Groups 
                Keywords 
                KeywordCategories 
                Photographers 
                Projects 
                ProjectKeywords 
                ProjectKeywordCategories 
                Searches
                SearchItems 
                Sizes 
                TextRewrites 
                Users
              ] 
    
    #Validate the right object type is passed for Noun's constructor
    def self.validate_argument(arg,val='NOUN')
        unless arg.is_a?(NilClass) || arg.is_a?(Hash)
            msg = "Argument Validation Error: Expected no argument or a \"Hash\" to create #{val} object." +
                  "\nInstead got a(n) #{arg.class} with contents => #{arg.inspect}"
            Logging::logger.error(msg)
            abort
        end
        return (arg) ? arg : Hash.new # Return arg or empty hash in case arg is nil
    end

    def self.process_http_response(response,verbose=nil,resource='',http_method='')
        err_header = ''
        case http_method
            when 'GET'
                err_header = "Retrieving \"#{resource}\""
            when'POST'
                err_header = "Creating \"#{resource}\""
            when 'PUT'
                err_header = "Updating \"#{resource}\""
            when 'DELETE'
                err_header = "Deleting \"#{resource}\""
            when 'HEAD'
                err_header = "Retrieving Header Data for \"#{resource}\""
        end
        
        if response.kind_of? Net::HTTPSuccess 
            msg = "Success: HTTP => #{response.code} #{response.message}"
            Logging::logger.info(msg.green)
        elsif response.kind_of? Net::HTTPRedirection 
            location = response['location']
            msg      = "Unexpected Redirect to #{location}"
            Logging::logger.error(msg.yellow) 
        elsif response.kind_of? Net::HTTPUnauthorized 
            msg = "Error: #{response.message}: Invalid Credentials."
            Logging::logger.error(msg) 
        elsif response.kind_of? Net::HTTPServerError
            
            code = "Code: #{response.code}"
            msg  = "Message: #{response.message}"

            if response.code.eql?('500') # Internal Server Error
                msg += ": Try again later."
                response.body = {'error_message' => "#{response.message}: Web Server Error - No idea what happened here.",'http_status_code' => "#{response.code}"}.to_json
            elsif response.code.eql?('502') # Bad Gateway
                response.body = {'error_message' => "#{response.message}: The server received an invalid response from the upstream server",
                                 'http_status_code' => "#{response.code}"}.to_json
            elsif response.code.eql?('503') # Service Unavailable => Web Server overloaded or temporarily down
                response.body = {'error_message' => "#{response.message}: The server is currently unavailable (because it is overloaded or down for maintenance)",
                                 'http_status_code' => "#{response.code}"}.to_json
            else
                response.body = {'error_message' => "#{response.message.to_s.gsub(/[<>/]+/,'')}",'http_status_code' => "#{response.code}"}.to_json
            end
            Logging::logger.error(code)
            Logging::logger.error(msg)
        else
            if response.body.include?('<title>OpenAsset - Something went wrong!</title>') && 
               !http_method.upcase.eql?('GET')
                    response.body = {'error_message' => 'Possibly unsupported file type: NGINX Error - OpenAsset - Something went wrong!','http_status_code' => "#{response.code}"}.to_json
            elsif response.code.eql?('403') && http_method.upcase.eql?('GET') &&
               response.body.include?('<title>OpenAsset - Something went wrong!</title>')
                    msg = "Don't let the error fool you. The image size specified is no longer available in S3. Go see the Wizard."
                    Logging::logger.error(msg)
            end        
        end
        return response
    end

    def self.validate_field_lookup_string_arg(field)
        id = nil
        #check for a field object or an id as a string or integer
            if field.is_a?(Fields)
                id = field.id
            elsif field.is_a?(Integer)
                id = field
            elsif field.is_a?(String) && field.to_i > 0
                id = field.to_i.to_s #In case something like "12abc" is passed it returns "12"
            elsif field.is_a?(Hash) && field.has_key?('id')
                id = field['id']
            else
                msg = "Argument Error in get_field_lookup_strings method:\n\tFirst Parameter Expected " + 
                      "one of the following so take your pick.\n\t1. Fields object\n\t2. Field object converted " +
                      "to Hash (e.g) field.json\n\t3. A hash just containing an id (e.g) {'id' => 1}\n\t" +
                      "4. A string or an Integer for the id\n\t5. An array of Integers of Numeric Strings"
                Logging::logger.error(msg)
                abort
            end
            return id
    end

    def self.validate_and_process_url(uri)
        #Perform all the checks for the url
        unless uri.is_a?(String)
            msg = "Expected a String for first argument => \"uri\": Instead Got #{uri.class}"
            Logging::logger.error(msg)
            abort
        end

        uri_with_protocol = Regexp::new('(^https:\/\/|http:\/\/)[\w-]+\.[\w-]+\.(com)$', true)

        uri_without_protocol = Regexp::new('^[\w-]+\.[\w-]+\.(com)$', true)

        uri_is_ip_address = Regexp::new('(http(s)?:\/\/)?(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})',true)

        if (uri_with_protocol =~ uri) == 0 #check for valid url and that protocol is specified
            uri
        elsif (uri_without_protocol =~ uri) == 0
            uri = "https://" + uri               
        elsif (uri_is_ip_address =~ uri) == 0
            unless uri.to_s.include?('http://') || uri.to_s.include?('https://')
                uri = 'http://' + uri.to_s          
            end
            # Only allow private IPs because public ones will fail due to SSL certificate error
            unless /http:\/\/10\.\d{1,3}\.\d{1,3}\.\d{1,3}/ =~ uri ||                # Class A IP range
                   /http:\/\/172\.(1[6-9]|2[0-9]|3[01])\.\d{1,3}\.\d{1,3}/ =~ uri || # Class B IP range
                   /http:\/\/192\.168\.\d{1,3}\.\d{1,3}/ =~ uri                      # Class C IP range

                msg = "Only private IP ranges allowed. Public IPs will trigger an SSL certificate error."
                Logging::logger.error(msg)
                abort
            end
            uri
        else
            msg = "Invalid url! Expected http(s)://<subdomain>.openasset.com" + 
                  "\nInstead got => #{uri.inspect}"
            Logging::logger.error(msg)
            abort
        end

    end

    def self.validate_and_process_request_data(data)
        json_object = nil
        
        if data.nil?
            msg = "Error: No body provided."
            Logging::logger.error(msg)
            return false
        end
            
        #Perform all the checks for what will be the body of the HTTP request
        if data.is_a?(Hash)
            json_object = data #Already in json object format
        elsif data.is_a?(Array) && data.size > 0
            if data.first.is_a?(Hash) #Array json objects
                json_object = data
            elsif Validator::NOUNS.include?(data.first.class.to_s) #Array of NOUN objects
                json_object = data.map {|noun_obj| noun_obj.json}
            end
        elsif Validator::NOUNS.include?(data.class.to_s) #Single object
            json_object = data.json #This means we have a noun object
        elsif data.is_a?(Array) && data.empty?
            msg = "Oops. Array is empty so there is nothing to send."
            Logging::logger.error(msg)
            return false
        else
            msg = "Argument Error: Expected either\n1. A NOUN object\n2. An Array of NOUN objects\n3. A Hash\n4. An Array of Hashes\n" +
                  "Instead got a #{data.class.to_s}."
            Logging::logger.error(msg)
            return false
        end
        return json_object
    end

    def self.validate_and_process_delete_body(data)
        json_object = nil
        
        #Perform all the checks for what will be the body of the delete request
        if data.is_a?(Hash)
            json_object = data #already a JSON object
        elsif data.is_a?(Integer) || data.is_a?(String)# if just an id is passed, create json object
            #Check if its an acutal number and not just random letters
            if data.to_i != 0
                json_object = Hash.new
                json_object['id'] = data.to_s
            else
                msg = "Expected an Integer or Numberic string for id in delete request body. Instead got #{data.inspect}"
                Logging::logger.error(msg)
                return false
            end
        elsif data.is_a?(Array) && data.size > 0
            if data.first.is_a?(Hash) #Array of JSON objects
                json_object = data
            elsif Validator::NOUNS.include?(data.first.class.to_s) #Array of objects
                json_object = data.map {|noun_obj| noun_obj.json} # Convert all the Noun objects to JSON objects, NOT JSON Strings
            elsif data.first.is_a?(String) || data.first.is_a?(Integer) #Array of id's
                json_object = data.map do |id_value|
                    if id_value.to_i == 0 
                        msg = "Invalid id value of #{id_value.inspect}. Skipping it."
                        Logging::logger.warn(msg.yellow)
                    else
                        {"id" => id_value.to_s}   # Convert each id into json object and return array of JSON objects
                    end
                end
            else
                msg = "Expected Array of id Strings or Integers but instead got => #{data.first.class.to_s}"
                Logging::logger.error(msg)
                return false
            end
        elsif Validator::NOUNS.include?(data.class.to_s) #Single object
            json_object = data.json # Convert Noun to JSON object (NOT JSON string. We do that right befor sending the request)
        elsif data.is_a?(Array) && data.empty?
            msg = "Oops. Array is empty so there is nothing to send."
            Logging::logger.error(msg)
            return false
        else
            msg = "Argument Error: Expected either\n\t1. A NOUN object\n\t2. An Array of NOUN objects" + 
                                  "\n\t3. A Hash\n\t4. An Array of Hashes\n\t5. An Array of id strings or integers\n\t" +
                                  "Instead got a => #{data.class.to_s}."
            Logging::logger.error(msg)
            return false
        end
        return json_object
    end

end