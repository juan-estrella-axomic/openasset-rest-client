
require 'Version/version.rb'

require_relative 'Authenticator.rb'
require_relative 'RestOptions.rb'
require_relative 'Helpers.rb'
require_relative 'Validator.rb'

#Includes all the nouns in one shot
Dir[File.join(File.dirname(__FILE__),'Nouns','*.rb')].each { |file| require_relative file }

module Openasset
	class RestClient
		
		RESTRICTED_LIST_FIELD_TYPES   = %w[ suggestion fixedSuggestion option ]
		NORMAL_FIELD_TYPES 		      = %w[ singleLine multiLine ]
		ALLOWED_BOOLEAN_FIELD_OPTIONS = %w[ enable disable yes no set unset check uncheck tick untick on off true false 1 0]
		attr_reader :session, :uri
		attr_accessor :verbose

		def initialize(client_url)
			oa_uri_with_protocol    = Regexp::new('(^https:\/\/|http:\/\/)\w+.+\w+.openasset.(com)$', true)
			oa_uri_without_protocol = Regexp::new('^\w+.+\w+.openasset.(com)$', true)

			unless oa_uri_with_protocol =~ client_url #check for valid url and that protocol is specified
				if oa_uri_without_protocol =~ client_url #verify correct url format
					client_url = "https://" + client_url #add the https protocol if one isn't provided
				else
					warn "Error: Invalid url! Expected http(s)://<subdomain>.openasset.com" + 
						 "\nInstead got => #{uri}"
					exit
				end
			end
			@authenticator = Authenticator::get_instance(client_url)
			@uri = @authenticator.uri
			@session = @authenticator.get_session
			@verbose = false
		end

		private
		def get(uri,options_obj=nil)
			resource = uri.to_s.split('/').last
			options = options_obj || RestOptions.new

			#Ensures File resource query returns all nested file sizes unless otherwise specified
			case resource 
			when 'Files'
				options.add_option('sizes','all')
				options.add_option('keywords','all')
				options.add_option('fields','all')
			when 'Albums'
				options.add_option('files','all')
				options.add_option('groups','all')
				options.add_option('users','all')
			when 'Projects'
				options.add_option('projectKeywords','all')
				options.add_option('fields','all')
			when 'Fields'
				options.add_option('fieldLookupStrings','all')
			when 'Searches'
				options.add_option('groups','all')
				options.add_option('users','all')
			else
				
			end
			
			response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
				request = Net::HTTP::Get.new(uri.request_uri + options.get_options)
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
			Validator::process_http_response(response,@verbose,resource,'GET')
				
			#Dynamically infer the the class needed to create objects by using the request_uri REST endpoint
			#returns the Class constant so we can dynamically set it below

			inferred_class = Object.const_get(resource)
		    
			objects_array = JSON.parse(response.body).map { |item| inferred_class.new(item) }
			
		end

		def post(uri,data=nil)
			resource = ''
			if uri.to_s.split('/').last.to_i == 0 #its a non numeric string meaning its a resource endpoint
				resource = uri.to_s.split('/').last
			else
				resource = uri.to_s.split('/')[-2] #the request is using a REST shortcut so we need to grab 
			end									   #second to last string of the url as the endpoint

			json_body = Validator::validate_and_process_request_data(data)
			unless json_body
				puts "Error: Undefined json_body Error in POST request."
				return false
			end
			response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
				request = Net::HTTP::Post.new(uri.request_uri)
				if @session
					request.add_field('X-SessionKey',@session)
				else
					@session = @authenticator.get_session
					request.add_field('X-SessionKey',@session) #For when the token issue is sorted out
					#request['authorization'] = "Basic YWRtaW5pc3RyYXRvcjphZG1pbg=="
				end
				request.body = json_body.to_json
				http.request(request)
			end

			unless @session == response['X-SessionKey']
				@session = response['X-SessionKey']
			end

			Validator::process_http_response(response,@verbose,resource,'POST')

		end

		def put(uri,data)
			resource = uri.to_s.split('/').last
			json_body = Validator::validate_and_process_request_data(data)
			unless json_body
				return
			end
			response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
				request = Net::HTTP::Put.new(uri.request_uri)
				if @session
					request.add_field('X-SessionKey',@session)
				else
					@session = @authenticator.get_session
					request.add_field('X-SessionKey',@session) #For when the token issue is sorted out
					#request['authorization'] = "Basic YWRtaW5pc3RyYXRvcjphZG1pbg=="
				end
				request.body = json_body.to_json
				http.request(request)
			end

			unless @session == response['X-SessionKey']
				@session = response['X-SessionKey']
			end

			Validator::process_http_response(response,@verbose,resource,'PUT') #JSON object retured
			
		end

		def delete(uri,body)
			resource = uri.to_s.split('/').last
			json_object = Validator::validate_and_process_delete_body(body)
			unless json_object
				return
			end
			response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
				request = Net::HTTP::Delete.new(uri.request_uri) #e.g. when called in keywords => /keywords/id
				if @session
					request.add_field('X-SessionKey',@session)
				else
					@session = @authenticator.get_session
					request.add_field('X-SessionKey',@session) #For when the token issue is sorted out
					#request['authorization'] = "Basic YWRtaW5pc3RyYXRvcjphZG1pbg=="
				end
				request.body = json_object.to_json
				http.request(request)
			end

			unless @session == response['X-SessionKey']
				@session = response['X-SessionKey']
			end

			Validator::process_http_response(response,@verbose,resource,'DELETE') #JSON object retured
		end
		
		public
		#########################
		#                       #
		#   Session Management  #
		#                       #
		#########################
		def kill_session
			@authenticator.kill_session
		end

		def get_session
			@authenticator.get_session
		end

		def renew_session
			@authenticator.kill_session
			@authenticator.get_session
		end
		
		####################################################
		#                                                  #
		#  Retrieve, Create, Modify, and Delete Resources  #
		#                                                  #
		####################################################


		#################
		#               #
		# ACCESS LEVELS #
		#               #
		#################
		def get_access_levels(query_obj=nil)
			uri = URI.parse(@uri + "/AccessLevels")
			results = get(uri,query_obj)
		end

		##########
		#        #
		# ALBUMS #
		#        #
		##########
		def get_albums(query_obj=nil)	
			uri = URI.parse(@uri + "/Albums")
			result = get(uri,query_obj)
		end

		def create_albums(data)
			uri = URI.parse(@uri + '/Albums')
			result = post(uri,data)
		end

		def update_albums(data=nil)
			uri = URI.parse(@uri + '/Albums')
			result = put(uri,data) 
		end
		
		def delete_albums(data=nil)
			uri = URI.parse(@uri + '/Albums')
			result = delete(uri,data)
		end

		####################
		#                  #
		# ALTERNATE STORES #
		#                  #
		####################
		def get_alternate_stores(query_obj=nil)
			uri = URI.parse(@uri + "/AlternateStores")
			results = get(uri,query_obj)
		end

		#################
		#               #
		# ASPECT RATIOS #
		#               #
		#################
		def get_aspect_ratios(query_obj=nil)
			uri = URI.parse(@uri + "/AspectRatios")
			results = get(uri,query_obj)
		end

		##############
		#            #
		# CATEGORIES #
		#            #
		##############
		def get_categories(query_obj=nil)
			uri = URI.parse(@uri + "/Categories")
			results = get(uri,query_obj)
		end

		def update_categories(data=nil)
			uri = URI.parse(@uri + "/Categories")
			results = put(uri,data)
		end

		#####################
		#                   #
		# COPYRIGHT HOLDERS #
		#                   #
		#####################
		def get_copyright_holders(query_obj=nil)
			uri = URI.parse(@uri + "/CopyrightHolders")
			results = get(uri,query_obj)
		end

		def create_copyright_holders(data=nil)
			uri = URI.parse(@uri + "/CopyrightHolders")
			results = post(uri,data)
		end

		def update_copyright_holders(data=nil)
			uri = URI.parse(@uri + "/CopyrightHolders")
			results = put(uri,data)
		end

		######################
		#                    #
		# COPYRIGHT POLICIES #
		#                    #
		######################
		def get_copyright_policies(query_obj=nil)
			uri = URI.parse(@uri + "/CopyrightPolicies")
			results = get(uri,query_obj)
		end

		def create_copyright_policies(data=nil)
			uri = URI.parse(@uri + "/CopyrightPolicies")
			results = post(uri,data)
		end

		def update_copyright_policies(data=nil)
			uri = URI.parse(@uri + "/CopyrightPolicies")
			results = put(uri,data)
		end

		def delete_copyright_policies(data=nil)
			uri = URI.parse(@uri + "/CopyrightPolicies")
			results = delete(uri,data)
		end

		##########
		#        #
		# FIELDS #
		#        #
		##########
		def get_fields(query_obj=nil)
			uri = URI.parse(@uri + "/Fields")
			results = get(uri,query_obj)
		end

		def create_fields(data=nil)
			uri = URI.parse(@uri + "/Fields")
			results = post(uri,data)
		end

		def update_fields(data=nil)
			uri = URI.parse(@uri + "/Fields")
			results = put(uri,data)
		end

		def delete_fields(data=nil)
			uri = URI.parse(@uri + "/Fields")
			results = delete(uri,data)
		end

		########################
		#                      #
		# FIELD LOOKUP STRINGS #
		#                      #
		########################
		def get_field_lookup_strings(field=nil,query_obj=nil)
			id = Validator::validate_field_lookup_string_arg(field)
			
			uri = URI.parse(@uri + '/Fields' + "/#{id}" +'/FieldLookupStrings')
			results = get(uri,query_obj)
		end

		def create_field_lookup_strings(field=nil,data=nil)
			id = Validator::validate_field_lookup_string_arg(field)
			
			uri = URI.parse(@uri + '/Fields' + "/#{id}" +'/FieldLookupStrings')
			results = post(uri,data)
		end

		def update_field_lookup_strings(field=nil,data=nil)
			id = Validator::validate_field_lookup_string_arg(field)
			
			uri = URI.parse(@uri + '/Fields' + "/#{id}" +'/FieldLookupStrings')
			results = put(uri,data)
		end

		def delete_field_lookup_strings(field=nil,data=nil)
			id = Validator::validate_field_lookup_string_arg(field)
			
			uri = URI.parse(@uri + '/Fields' + "/#{id}" +'/FieldLookupStrings')
			results = delete(uri,data)
		end

		#########
		#       #
		# FILES #
		#       #
		#########
		def get_files(query_obj=nil)
			uri = URI.parse(@uri + "/Files")
			results = get(uri,query_obj)
		end

		def upload_file(file, category_id, project_id='') 
		
			unless File.exists?(file.to_s)
				puts "Error: The file provided does not exist -\"#{file}\"...Bailing out."
				return false
			end

			unless category_id.to_i > 0
				puts "Argument Error for upload_files method: Invalid category code passed to second argument."
				return false
			end

			uri = URI.parse(@uri + "/Files")
			boundary = (0...50).map { (65 + rand(26)).chr }.join #genererate a random str thats 50 char long
			body = Array.new

			response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
				request = Net::HTTP::Post.new(uri.request_uri)
				
				if @session
					request.add_field('X-SessionKey',@session)
				else
					@session = @authenticator.get_session
					request.add_field('X-SessionKey',@session)
				end

				request["cache-control"] = 'no-cache'
				request["content-type"] = 'multipart/form-data; boundary=----WebKitFormBoundary' + boundary

				body << "------WebKitFormBoundary#{boundary}\r\nContent-Disposition: form-data; name=\"_jsonBody\"" 
				body << "\r\n\r\n[{\"original_filename\":\"#{File.basename(file)}\",\"category_id\":#{category_id},\"project_id\":\"#{project_id}\"}]\r\n"
				body << "------WebKitFormBoundary#{boundary}\r\nContent-Disposition: form-data; name=\"file\";"
				body << "filename=\"#{File.basename(file)}\"\r\nContent-Type: #{MIME::Types.type_for(file)}\r\n\r\n"
				body << IO.binread(file)
				body << "\r\n------WebKitFormBoundary#{boundary}--"

				request.body = body.join
				http.request(request)
			end
			Validator::process_http_response(response,@verbose,'Files','POST')		
		end

		def replace_file(original_file_object, replacement_file_path='', retain_original_filename_in_oa=false) 
			file_object = (original_file_object.is_a?(Array)) ? original_file_object.first : original_file_object
			uri = URI.parse(@uri + "/Files")
			id = file_object.id.to_s
			original_filename = nil

			# raise an Error if something other than an file object is passed in. Check the class
			unless file_object.is_a?(Files) 
				puts "ARGUMENT ERROR: First argument => Invalid object type! Expected File object" +
				     " and got #{file_obj.class} object instead. Aborting update." 
				return false
			end
			
			if File.directory?(replacement_file_path)
				puts "ARGUMENT ERROR: Second argument => Expected a file! " +
					 "#{replacement_file_path} is a directory! Aborting update."
			end


			#check if the replacement file exists
			unless File.exists?(replacement_file_path) && File.file?(replacement_file_path)
				puts "ERROR: The file #{replacement_file_path} does not exist. Aborting update."
				return false
			end

			#verify that both files have the same file extentions otherwise you will
			#get a 400 Bad Request Error
			if File.extname(file_object.original_filename) != File.extname(replacement_file_path)
				puts "ERROR: File extensions must match! Aborting update\n\t" + 
					 "Original file extension => #{File.extname(file_object.original_filename)}\n\t" +
					 "Replacement file extension => #{File.extname(replacement_file_path)}"
				return false
			end

			#verify that the original file id is provided
			unless id != "0"
				puts "ERROR: Invalid target file id! Aborting update."
				return false
			end

			#change in format
			if retain_original_filename_in_oa == true
				unless file_object.original_filename == nil || file_object.original_filename == ''
	
					original_filename = File.basename(file_object.original_filename)
				else
					warn "ERROR: No original filename detected in Files object. Aborting update."
					return false
				end
			else
				original_filename = File.basename(replacement_file_path)
			end 

			body = Array.new

			response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
				request = Net::HTTP::Put.new(uri.request_uri)
				request["content-type"] = 'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW'
				if @session
					request.add_field('X-SessionKey',@session)
				else
					@session = @authenticator.get_session
					request.add_field('X-SessionKey',@session)
				end
				request["cache-control"] = 'no-cache'
				body << "------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"_jsonBody\""  
				body << "\r\n\r\n[{\"id\":\"#{id}\",\"original_filename\":\"#{original_filename}\"}]\r\n"
				body << "------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"file\";" 
				body << "filename=\"#{original_filename}\"\r\nContent-Type: #{MIME::Types.type_for(original_filename)}\r\n\r\n"
				body << IO.binread(replacement_file_path)
				body << "\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW--"
				request.body = body.join
				http.request(request)
			end
			Validator::process_http_response(response,@verbose,'Files', 'PUT')	
		end

		def update_files(data=nil)
			uri = URI.parse(@uri + "/Files")
			results = put(uri,data)
		end

		def delete_files(data=nil)
			uri = URI.parse(@uri + "/Files")
			results = delete(uri,data)
		end
        
        ##########
		#        #
		# GROUPS #
		#        #
		##########
		def get_groups(query_obj=nil)
			uri = URI.parse(@uri + "/Groups")
			results = get(uri,query_obj)
		end

		############
		#          #
		# KEYWORDS #
		#          #
		############
		def get_keywords(query_obj=nil)
			uri = URI.parse(@uri + "/Keywords")
			results = get(uri,query_obj)
		end

		def create_keywords(data=nil)
			uri = URI.parse(@uri + "/Keywords")
			results = post(uri,data)
		end

		def update_keywords(data=nil)
			uri = URI.parse(@uri + "/Keywords")
			results = put(uri,data)
		end

		def delete_keywords(data=nil)
			uri = URI.parse(@uri + "/Keywords")
			results = delete(uri,data)
		end

		######################
		#                    #
		# KEYWORD CATEGORIES #
		#                    #
		######################
		def get_keyword_categories(query_obj=nil)
			uri = URI.parse(@uri + "/KeywordCategories")
			results = get(uri,query_obj)
		end

		def create_keyword_categories(data=nil)
			uri = URI.parse(@uri + "/KeywordCategories")
			results = post(uri,data)
		end

		def update_keyword_categories(data=nil)
			uri = URI.parse(@uri + "/KeywordCategories")
			results = put(uri,data)
		end

		def delete_keyword_categories(data=nil)
			uri = URI.parse(@uri + "/KeywordCategories")
			results = delete(uri,data)
		end

		#################
		#               #
		# PHOTOGRAPHERS #
		#               #
		#################
		def get_photographers(query_obj=nil)
			uri = URI.parse(@uri + "/Photographers")
			results = get(uri,query_obj)
		end

		def create_photographers(data=nil)
			uri = URI.parse(@uri + "/Photographers")
			results = post(uri,data)
		end

		def update_photographers(data=nil)
			uri = URI.parse(@uri + "/Photographers")
			results = put(uri,data)
		end

		############
		#          #
		# PROJECTS #
		#          #
		############
		def get_projects(query_obj=nil)
			uri = URI.parse(@uri + "/Projects")
			results = get(uri,query_obj)
		end

		def create_projects(data=nil)
			uri = URI.parse(@uri + "/Projects")
			results = post(uri,data)
		end

		def update_projects(data=nil)
			uri = URI.parse(@uri + "/Projects")
			results = put(uri,data)
		end

		def delete_projects(data=nil)
			uri = URI.parse(@uri + "/Projects")
			results = delete(uri,data)
		end

		####################
		#                  #
		# PROJECT KEYWORDS #
		#                  #
		####################
		def get_project_keywords(query_obj=nil)
			uri = URI.parse(@uri + "/ProjectKeywords")
			results = get(uri,query_obj)
		end

		def create_project_keywords(data=nil)
			uri = URI.parse(@uri + "/ProjectKeywords")
			results = post(uri,data)
		end

		def update_project_keywords(data=nil)
			uri = URI.parse(@uri + "/ProjectKeywords")
			results = put(uri,data)
		end

		def delete_project_keywords(data=nil)
			uri = URI.parse(@uri + "/ProjectKeywords")
			results = delete(uri,data)
		end

		##############################
		#                            #
		# PROJECT KEYWORD CATEGORIES #
		#                            #
		##############################
		def get_project_keyword_categories(query_obj=nil)
			uri = URI.parse(@uri + "/ProjectKeywordCategories")
			results = get(uri,query_obj)
		end

		def create_project_keyword_categories(data=nil)
			uri = URI.parse(@uri + "/ProjectKeywordCategories")
			results = post(uri,data)
		end

		def update_project_keyword_categories(data=nil)
			uri = URI.parse(@uri + "/ProjectKeywordCategories")
			results = put(uri,data)
		end

		def delete_project_keyword_categories(data=nil)
			uri = URI.parse(@uri + "/ProjectKeywordCategories")
			results = delete(uri,data)
		end

		############
		#          #
		# SEARCHES #
		#          #
		############
		def get_searches(query_obj=nil)
			uri = URI.parse(@uri + "/Searches")
			results = get(uri,query_obj)
		end

		def create_searches(data=nil)
			uri = URI.parse(@uri + "/Searches")
			results = post(uri,data)
		end

		def update_searches(data=nil)
			uri = URI.parse(@uri + "/Searches")
			results = put(uri,data)
		end

		#########
		#       #
		# SIZES #
		#       #
		#########
		def get_image_sizes(query_obj=nil)
			uri = URI.parse(@uri + "/Sizes")
			results = get(uri,query_obj)
		end

		def create_image_sizes(data=nil)
			uri = URI.parse(@uri + "/Sizes")
			results = post(uri,data)
		end

		def update_image_sizes(data=nil)
			uri = URI.parse(@uri + "/Sizes")
			results = put(uri,data)
		end

		def delete_image_sizes(data=nil)
			uri = URI.parse(@uri + "/Sizes")
			results = delete(uri,data)
		end

		#################
		#               #
		# TEXT REWRITES #
		#               #
		#################
		def get_text_rewrites(query_obj=nil)
			uri = URI.parse(@uri + "/TextRewrites")
			results = get(uri,query_obj)
		end

		#########
		#       #
		# USERS #
		#       #
		#########
		def get_users(query_obj=nil)
			uri = URI.parse(@uri + "/Users")
			results = get(uri,query_obj)
		end

		############################
		#                          #
		# Administrative Functions #
		#                          #
		############################
		def file_add_keywords(files=nil,keywords=nil)
		
			#1.validate class types
			#Looking for File objects or an array of File objects
			unless files.is_a?(Files) || (files.is_a?(Array) && files.first.is_a?(Files))
				warn "Argument Error: Invalid type for first argument in \"file_add_keywords\" method.\n" +
					 "\tExpected one the following:\n" +
					 "\t1. Single Files object\n" +
					 "\t2. Array of Files objects\n" +
					 "\tInstead got => #{files.inspect}"
				return false			
			end 

			unless keywords.is_a?(Keywords) || (keywords.is_a?(Array) && keywords.first.is_a?(Keywords))
				warn "Argument Error: Invalid type for second argument in \"file_add_keywords\" method.\n" +
					 "\tExpected one the following:\n" +
					 "\t1. Single Keywords object\n" +
					 "\t2. Array of Keywords objects\n" +
					 "\tInstead got => #{keywords.inspect}"
				return false			
			end 
			
			#2.build file json array for request body
			#There are four acceptable combinations for the arguments.
		 
			if files.is_a?(Files)  
				if keywords.is_a?(Keywords) #1. Two Single objects
					uri = URI.parse(@uri + "/Files/#{files.id}/Keywords/#{keywords.id}")
					post(uri,{})
				else						#2. One File object and an array of Keywords objects
					#loop through keywords objects and append the new nested keyword to the file
					keywords.each do |keyword|
						files.keywords << NestedKeywordItems.new(keyword.id)
					end  
					uri = URI.parse(@uri + "/Files")
					put(uri,files)
				end
			else		
				if keywords.is_a?(Array)	#3. Two arrays
					keywords.each do |keyword|
						uri = URI.parse(@uri + "/Keywords/#{keyword.id}/Files")
						data = files.map { |files_obj| {:id => files_obj.id} }
						post(uri,data)
					end
				else						#4. Files array and a single Keywords object
					uri = URI.parse(@uri + "/Keywords/#{keywords.id}/Files")
					data = files.map { |files_obj| {:id => files_obj.id} }
					post(uri,data)
				end
			end
			
		end

		def project_add_keywords(projects=nil,proj_keywords=nil)
			
			#1.validate class types
			#Looking for Project objects or an array of Project objects
			unless projects.is_a?(Projects) || (projects.is_a?(Array) && 
					projects.first.is_a?(Projects))
				warn "Argument Error: Invalid type for first argument in \"project_add_keywords\" method.\n" +
					 "\tExpected one the following:\n" +
					 "\t1. Single Projects object\n" +
					 "\t2. Array of Projects objects\n" +
					 "\tInstead got => #{projects.inspect}"
				return false			
			end 

			unless project_keywords.is_a?(ProjectKeywords) || (project_keywords.is_a?(Array) && 
					project_keywords.first.is_a?(ProjectKeywords))
				warn "Argument Error: Invalid type for second argument in \"project_add_keywords\" method.\n" +
					 "\tExpected one the following:\n" +
					 "\t1. Single ProjectKeywords object\n" +
					 "\t2. Array of ProjectKeywords objects\n" +
					 "\tInstead got => #{proj_keywords.inspect}"
				return false			
			end 
			#2.build project json array for request body
			#There are four acceptable combinations for the arguments.
		 	project_keyword = Struct.new(:id)

			if projects.is_a?(Projects)  
				if project_keywords.is_a?(ProjectKeywords) #1. Two Single objects
					uri = URI.parse(@uri + "/Projects/#{projects.id}/ProjectKeywords/#{proj_keywords.id}")
					post(uri,{})
				else						#2. One Project object and an array of project Keyword objects
					#loop through Projects objects and append the new nested keyword to them
					proj_keywords.each do |keyword|
						projects.project_keywords << project_keyword.new(keyword.id)  
					end
					uri = URI.parse(@uri + "/Projects")
					put(uri,projects)
				end
			else 		
				if keywords.is_a?(Array)	#3. Two arrays
					projects.each do |proj|
						proj_keywords.each do |keyword|
							proj.project_keywords << project_keyword.new(keyword.id)
						end
					end
					uri = URI.parse(@uri + "/Projects")
					put(uri,projects)
				else						#4. Projects array and a single Keywords object
					projects.each do |proj|
						proj.project_keywords << project_keyword.new(proj_keywords.id)
					end	
					uri = URI.parse(@uri + "/Projects") #/ProjectKeywords/:id/Projects 
					put(uri,projects)					#shortcut not implemented yet					
				end
			end
		end

		def file_add_field_data(file=nil,field=nil,value=nil)
	
			current_file  = nil
			current_field = nil
			current_value = value.to_s.strip

			#validate class types
			unless file.is_a?(Files) || (file.is_a?(String) && (file.to_i != 0)) || file.is_a?(Integer)
				warn "Argument Error: Invalid type for first argument in \"file_add_field_data\" method.\n" +
					 "\tExpected Single Files object, Numeric string, or Integer for file id\n" +
					 "\tInstead got => #{file.inspect}"
				return			
			end 

			unless field.is_a?(Fields) ||  (field.is_a?(String) && (field.to_i != 0)) || field.is_a?(Integer)
				warn "Argument Error: Invalid type for second argument in \"file_add_field_data\" method.\n" +
					 "\tExpected Single Fields object, Numeric string, or Integer for field id\n" +
					 "\tInstead got => #{field.inspect}"
				return 			
			end

			unless value.is_a?(String) || value.is_a?(Integer)
				warn "Argument Error: Invalid type for third argument in \"file_add_field_data\" method.\n" +
					 "\tExpected a String or an Integer\n" +
					 "\tInstead got => #{value.inspect}"
				return			
			end

			file_class  = file.class.to_s
			field_class = field.class.to_s

			#set up objects
			if file_class == 'Files'
				current_file = file
			elsif file_class == 'String' || file_class == 'Integer' 
				#retrieve Projects object matching id provided
				uri = URI.parse(@uri + "/Files")
				option = RestOptions.new
				option.add_option("id",file.to_s)
				current_file = get(uri,option).first
				unless current_file
					warn "ERROR: Could not find Project with matching id of \"#{file.to_s}\"...Exiting"
					return
				end
			else
				warn "Unknown Error retrieving Files. Exiting."
				return
			end

			if field_class == 'Fields'
				current_field = field
			elsif field_class == 'String' || field_class == 'Integer'
				uri = URI.parse(@uri + "/Fields")
				option = RestOptions.new
				option.add_option("id",field.to_s)
				current_field = get(uri,option).first
				unless current_field
					warn "ERROR: Could not find Field with matching id of \"#{field.to_s}\"\n" +
						 "=> Hint: It either doesn't exist or it's disabled."
					return false
				end
				unless current_field.field_type == "image"
					warn "ERROR: Expected a Project field. The field provided is a \"#{current_field.field_type}\" field."
					return false
				end		
			else
				warn "Unknown Error retrieving Field. Exiting."
				return
			end

			#Prep endpoint to be used for update
			files_endpoint = URI.parse(@uri + "/Files/#{current_file.id}/Fields")

			#Check the field type -> if its option or fixed suggestion we must make the option
			#available first before we can apply it to the Files resource
			if RESTRICTED_LIST_FIELD_TYPES.include?(current_field.field_display_type)
				
				lookup_string_endpoint = URI.parse(@uri + "/Fields/#{current_field.id}/FieldLookupStrings")

				#Grab all the available FieldLookupStrings for the specified Fields resource
				field_lookup_strings = get(lookup_string_endpoint)

				#check if the value in the third argument is currently an available option for the field
				lookup_string_exists = field_lookup_strings.find { |item| item.value == value }

				#add the option to the restricted field first if it's not there, otherwise you get a 400 bad 
				#request error saying that it couldn't find the string value for the restricted field specified 
				#when making a PUT request on the FILES resource you are currently working on
				unless lookup_string_exists
					data = {:value => current_value}
					response = post(lookup_string_endpoint,data)
					return unless response.kind_of? Net::HTTPSuccess
				end

				#Now that we know the option is available, we can update the Files 
				#NOUN we are currently working with using a PUT request
				data = {:id => current_field.id, :values => [current_value]}
				put(files_endpoint,data)

			elsif current_field.field_display_type == "date"
				#make sure we get the right date format
				#Accepts mm-dd-yyyy, mm-dd-yy, mm/dd/yyyy, mm/dd/yy
				date_regex = Regexp::new('((\d{2}-\d{2}-(\d{4}|\d{2}))|(\d{2}\/\d{2}\/(\d{4}|\d{2})))')
				unless (value =~ date_regex) == 0
					warn "ERROR: Invalid date format. Expected => \"mm-dd-yyyy\" or \"mm-dd-yy\""
					return
				end

				value.gsub!('/','-')
				date_arr = value.split('-') #convert date string to array for easy manipulation

				if date_arr.last.length == 2  #convert mm-dd-yy to mm-dd-yyyy format
					four_digit_year = '20' + date_arr.last
					date_arr[-1] = four_digit_year
				end
				#convert date to 14 digit unix time stamp
				value = date_arr[-1] + date_arr[-3] + date_arr[-2] + '000000'

				#Apply the date to our current Files resource
				data = {:id => current_field.id, :values => [value.to_s]}
				put(files_endpoint,data)


			elsif NORMAL_FIELD_TYPES.include?(current_field.field_display_type)
				#some fields are built into Files so they can't be inserted into
				#the Files nested fields resource. We get around this by using the
				#name of the field object to access the corresponding built-in field attribute
				#inside the Files object.
				if current_field.built_in.to_s == "1"  #For built in fields
					files_endpoint =  URI.parse(@uri + '/Files') #change endpoint bc field is builtin
					field_name = current_field.name.downcase.gsub(' ','_') #convert the current field's name
																		   #into the associated files' builtin attribute name
					unless current_file.instance_variable_defined?('@'+field_name)
						warn "ERROR: The specified attirbute \"#{field_name}\" does not" + 
						     " exist in the File. Exiting."
						exit
					end
					
					current_file.instance_variable_set('@'+field_name, value)
					put(files_endpoint,current_file)
				else									#For regular non-built in fields
					data = {:id => current_field.id, :values => [value.to_s]}
					put(files_endpoint,data)
					
				end

			elsif current_field.field_display_type == 'boolean'

				#validate value
				unless ALLOWED_BOOLEAN_FIELD_OPTIONS.include?(value.to_s.strip)
					puts "ERROR: Invalid value #{value.inspect} for \"On/Off Switch\" field type.\n" +
						  "Acceptable Values => #{ALLOWED_BOOLEAN_FIELD_OPTIONS.inspect}"
					return false
				end
				
				
				#Interpret input
				#Even indicies in the field options array are On and Odd indicies are Off
				bool_val = ""
				if ALLOWED_BOOLEAN_FIELD_OPTIONS.find_index(value.to_s.strip).even?
					bool_val = "1"
				elsif ALLOWED_BOOLEAN_FIELD_OPTIONS.find_index(value.to_s.strip).odd?
					bool_val = "0"
				end

				#Prep the endpoint
				files_endpoint =  URI.parse(@uri + '/Files')

				current_file.fields.each do |obj| 
					if obj.id == current_field.id
						obj.values[0] = bool_val
					end
					
				end
				#udatte current variable for verbose statement
				current_value = bool_val
				#Actually do the update
				put(files_endpoint,current_file)
			else
				warn "Error: The field specified does not have a valid field_display_type." +
					 "Value provided => #{field.field_display_type.inspect}"
			end

			if @verbose
				puts "Setting value: \"#{current_value}\" to \"#{current_field.name}\" field " +
					 "for file => #{current_file.filename}"
			end
		end


		def project_add_field_data(project=nil,field=nil,value=nil)
			#NOTE: Date fields use the mm-dd-yyyy format
			current_project = nil
			current_field   = nil
			current_value	= value.to_s.strip


			#validate class types
			unless project.is_a?(Projects) || (project.is_a?(String) && (project.to_i != 0)) || project.is_a?(Integer)
				warn "Argument Error: Invalid type for first argument in \"project_add_field_data\" method.\n" +
					 "\tExpected Single Projects object, a Numeric string or Integer for a Project id\n" +
					 "\tInstead got => #{project.inspect}"
				return			
			end 

			unless field.is_a?(Fields) ||  (field.is_a?(String) && (field.to_i != 0)) || field.is_a?(Integer)
				warn "Argument Error: Invalid type for second argument in \"project_add_field_data\" method.\n" +
					 "\tExpected Single Projects object, Numeric string, or Integer for Projects id.\n" +
					 "\tInstead got => #{field.inspect}"
				return			
			end

			unless value.is_a?(String) || value.is_a?(Integer)
				warn "Argument Error: Invalid type for third argument in \"project_add_field_data\" method.\n" +
					 "\tExpected a String or an Integer.\n" +
					 "\tInstead got => #{value.inspect}"
				return			
			end

			project_class  = project.class.to_s
			field_class    = field.class.to_s

			#set up objects
			if project_class == 'Projects'
				current_project = project
			elsif project_class == 'String' || project_class == 'Integer' 
				#retrieve Projects object matching id provided
				uri = URI.parse(@uri + "/Projects")
				option = RestOptions.new
				option.add_option("id",project.to_s)
				current_project = get(uri,option).first
				unless current_project
					warn "ERROR: Could not find Project with matching id of \"#{project.to_s}\"...Exiting"
					return
				end
			else
				warn "Unknown Error retrieving project. Exiting."
				return
			end

			if field_class == 'Fields'
				current_field = field
			elsif field_class == 'String' || field_class == 'Integer'
				uri = URI.parse(@uri + "/Fields")
				option = RestOptions.new
				option.add_option("id",field.to_s)
				current_field = get(uri,option).first
				unless current_field
					warn "ERROR: Could not find Field with matching id of \"#{field.to_s}\"\n" +
						 "=> Hint: It either doesn't exist or it's disabled."
					return false
				end
				unless current_field.field_type == "project"
					warn "ERROR: Expected a Project field. The field provided is a \"#{current_field.field_type}\" field."
					return false
				end		
			else
				warn "Unknown Error retrieving field. Exiting."
				return
			end

			#Prep endpoint shortcut to be used for update
			projects_endpoint = URI.parse(@uri + "/Projects/#{current_project.id}/Fields")

			#Check the field type -> if its option or fixed suggestion we must make the option
			#available first before we can apply it to the Files resource
			if RESTRICTED_LIST_FIELD_TYPES.include?(current_field.field_display_type)
				
				lookup_string_endpoint = URI.parse(@uri + "/Fields/#{current_field.id}/FieldLookupStrings")

				#Grab all the available FieldLookupStrings for the specified Fields resource
				field_lookup_strings = get(lookup_string_endpoint)

				#check if the value in the third argument is currently an available option for the field
				lookup_string_exists = field_lookup_strings.find { |item| item.value == value }

				#add the option to the restricted field first if it's not there, otherwise you get a 400 bad 
				#request error saying that it couldn't find the string value for the restricted field specified 
				#when making a PUT request on the PROJECTS resource you are currently working on
				unless lookup_string_exists
					data = {:value => value}
					response = post(lookup_string_endpoint,data)
					return unless response.kind_of? Net::HTTPSuccess
				end

				#Now that we know the option is available, we can update the Projects 
				#NOUN we are currently working with using a PUT request
				data = {:id => current_field.id, :values => [value.to_s]}
				put(projects_endpoint,data)

				if @verbose
					puts "Adding value: \"#{value}\" to \"#{current_field.name}\" field" +
						 "for project => #{current_project.code} - #{current_project.name}"
				end


			elsif current_field.field_display_type == "date"
				#make sure we get the right date format
				#Accepts mm-dd-yyyy, mm-dd-yy, mm/dd/yyyy, mm/dd/yy
				date_regex = Regexp::new('((\d{2}-\d{2}-(\d{4}|\d{2}))|(\d{2}\/\d{2}\/(\d{4}|\d{2})))')
				unless (value =~ date_regex) == 0
					warn "ERROR: Invalid date format. Expected => \"mm-dd-yyyy\" or \"mm-dd-yy\""
					return
				end

				value.gsub!('/','-')
				date_arr = value.split('-') #convert date string to array for easy manipulation

				if date_arr.last.length == 2  #convert mm-dd-yy to mm-dd-yyyy format
					four_digit_year = '20' + date_arr.last

					date_arr[-1] = four_digit_year
				end
				#convert date to 14 digit unix time stamp
				value = date_arr[-1] + date_arr[-3] + date_arr[-2] + '000000'

				#Apply the date to our current Files resource
				data = {:id => current_field.id, :values => [value.to_s]}
				put(projects_endpoint,data) #Make the update

				
			elsif NORMAL_FIELD_TYPES.include?(current_field.field_display_type) #For regular fields
				#some fields are built into Projects so they can't be inserted into
				#the Projects nested fields resource. We get around this by using the
				#name of the field object to access the corresponding built-in field attribute
				#inside the Projects object.
				
				if current_field.built_in.to_s == "1"  #For built in fields
					projects_endpoint =  URI.parse(@uri + '/Projects') #change endpoint bc field is builtin
					field_name = current_field.name.downcase.gsub(' ','_')
					
					unless current_project.instance_variable_defined?('@'+field_name)
						warn "ERROR: The specified attirbute \"#{field_name}\" does not" + 
						     " exist in the Project. Exiting."
						exit
					end
					#update the project
					current_project.instance_variable_set('@'+field_name, value)
					#Make the update request
					put(projects_endpoint,current_project)                 

				else														#For regular non-built in fields
					data = {:id => current_field.id, :values => [value.to_s]}
					put(projects_endpoint,data)
				end
			elsif current_field.field_display_type == 'boolean'

				#validate value
				unless ALLOWED_BOOLEAN_FIELD_OPTIONS.include?(value.to_s.strip)
					puts "Error: Invalid value #{value.inspect} for \"On/Off Switch\" field type.\n" +
						  "Acceptable Values => #{ALLOWED_BOOLEAN_FIELD_OPTIONS.inspect}"
					return false
				end
				
				#Interpret input
				#Even indicies in the field options array are On and Odd indicies are Off
				bool_val = ""
				if ALLOWED_BOOLEAN_FIELD_OPTIONS.find_index(value.to_s.strip).even?
					bool_val = "1"
				elsif ALLOWED_BOOLEAN_FIELD_OPTIONS.find_index(value.to_s.strip).odd?
					bool_val = "0"
				end
				
				#Update the object
				projects_endpoint =  URI.parse(@uri + '/Projects')

				current_project.fields.each do |obj| 
					if obj.id == current_field.id
						obj.values[0] = bool_val
					end
					#obj
				end
				
				#Update current value variable for @verbose statement below
				current_value = bool_val

				#Acutally perform the update request
				put(projects_endpoint,current_project)
			else
				warn "Error: The field specified does not have a valid field_display_type." +
					 "Value provided => #{field.field_display_type.inspect}"
			end

			if @verbose
				puts "Setting value: \"#{current_value}\" to \"#{current_field.name}\" field " +
					 "for project => #{current_project.code} - #{current_project.name}"
			end
		end

	end
end
