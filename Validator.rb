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
		unless  arg.is_a?(NilClass) || arg.is_a?(Hash)
			warn "Argument Validation Error: Expected no argument or a \"Hash\" to create #{val} object." +
				 "\nInstead got a(n) #{arg.class} with contents => \"#{arg}\""
			exit
		end
		return (arg) ? arg : Hash.new #Return arg or empty hash in case arg is nil
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
		end
		
		if response.kind_of? Net::HTTPSuccess 
			puts "Success: HTTP => #{response.code} #{response.message}" if verbose
			return response
		elsif response.kind_of? Net::HTTPRedirection 
			location = response['location']
			warn "Warning: Redirected to #{location}"
			return response
		elsif response.kind_of? Net::HTTPUnauthorized 
			warn "Error: #{response.message}: invalid credentials."
			return response
		elsif response.kind_of? Net::HTTPServerError 
			warn "Error: #{response.message}: try again later."
			return response
		else
			warn "Error #{err_header} resource.\n\tMETHOD: #{http_method}\n\tCODE: #{response.code}" + 
			     "\n\tMESSAGE: #{response.message} #{response.body}\n\tRESOURCE: #{resource}" 
				 
			return response
		end
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
				warn "Argument Error in get_field_lookup_strings method:\n\tFirst Parameter Expected " + 
					 "one of the following so take your pick.\n\t1. Fields object\n\t2. Field object converted " +
					 "to Hash (e.g) field.json\n\t3. A hash just containing an id (e.g) {'id' => 1}\n\t" +
					 "4. A string or an Integer for the id  "
				exit
			end
			return id
	end

	def self.validate_url(uri)
		#Perform all the checks for the url
		unless uri.is_a?(String)
			warn "Expected a String for first argument => \"uri\": Instead Got #{uri.class}"
			exit
		end

		uri_with_protocol    = Regexp::new('(^https:\/\/|http:\/\/)\w+.+\w+.openasset.(com)$', true)
		uri_without_protocol = Regexp::new('^\w+.+\w+.openasset.(com)$', true)

		unless uri_with_protocol =~ uri #check for valid url and that protocol is specified
			if uri_without_protocol =~ uri #verify correct url format
				uri = "https://" + uri #add the https protocol if one isn't provided
			else
				warn "Error: Invalid url! Expected http(s)://<subdomain>.openasset.com" + 
					 "\nInstead got => #{uri}"
				exit
			end
		end

	end

	def self.validate_and_process_request_data(data)
		json_object = nil
		
		if data.nil?
			warn "Error: No body provided."
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
			warn "Oops. Array is empty so there is nothing to send."
			return false
		else
			warn "Argument Error: Expected either\n1. A NOUN object\n2. An Array of NOUN objects\n3. A Hash\n4. An Array of Hashes\n" +
				"Instead got a #{data.class.to_s}."
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
				warn  "Error: Expected an Integer or Numberic string for id. Instead got '#{data.inspect}'"
				false
			end
		elsif data.is_a?(Array) && data.size > 0
			if data.first.is_a?(Hash) #Array of JSON objects
				json_object = data
			elsif Validator::NOUNS.include?(data.first.class.to_s) #Array of objects
				json_object = data.map {|noun_obj| noun_obj.json} #convert all the Noun objects to JSON objects, NOT JSON Strings
			elsif data.first.is_a?(String) || data.first.is_a?(Integer) #Array of id's
				json_object = data.map do |id_value|
					if id_value.to_i == 0 
						puts "Invalid id value of #{id_value.inspect}. Skipping it."
					else
						{"id" => id_value.to_s}   #Convert each id into json object and return array of JSON objects
					end
				end
			else
				warn "Error: Expected Array of id strings or ints but instead got => #{data.first.class.to_s}"
				return false
			end
		elsif Validator::NOUNS.include?(data.class.to_s) #Single object
			json_object = data.json #convert Noun to JSON object (NOT JSON string. We do that right befor sending the request)
		elsif data.is_a?(Array) && data.empty?
			warn "Oops. Array is empty so there is nothing to send."
			return false
		else
			warn "Argument Error: Expected either\n\t1. A NOUN object\n\t2. An Array of NOUN objects" + 
						          "\n\t3. A Hash\n\t4. An Array of Hashes\n\t5. An Array of id strings or integers\n\t" +
						          "Instead got a => #{data.class.to_s}."
			return false
		end
		return json_object
	end

end