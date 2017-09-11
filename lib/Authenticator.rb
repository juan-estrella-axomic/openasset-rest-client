#My User Agent ->  Mozilla/5.0 (Windows NT 10.0; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0

require 'date'
require 'certified'
require 'net/http'
require 'json'
require 'uri'
require 'digest/sha1'
require 'base64'
require 'mime/types'
require 'fileutils'
require 'io/console'
require 'logger'
require 'yaml'  #for storing data locally


require_relative 'Helpers.rb'
require_relative 'Validator.rb'
require_relative 'Security.rb'


#use this class to generate a token
#use http post request to get token using the authenticationToken endpoint, grab ret

#Authentication
class Authenticator

	#@@DOMAIN_CONST = 'https://se1.openasset.com'
	@@API_CONST = '/REST'
	@@VERSION_CONST = '/1'
	@@SERVICE_CONST = '/AuthenticationTokens'

	attr_reader :uri

	private
	def initialize(url)
		Validator::validate_url(url)
		@username = ''
		@password = ''
		@url = url
		@uri = @url + @@API_CONST + @@VERSION_CONST
		@token_endpoint = @url + @@API_CONST + @@VERSION_CONST + @@SERVICE_CONST
		@token = {:id => nil, :value => nil}
		@session_key 
		@http_date 
		@user_agent = 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0'
		@signature = ''
	end

	
	def get_credentials
		u = ''
		p = ''
		while u == '' || p == ''
			print "Enter username: "
			u=gets.chomp
			print "Enter password: "
			p=STDIN.noecho(&:gets).chomp
			puts ''
			puts "Invalid username."  if u == ''
			puts "Invalid password."  if p == ''
		end
		@username = u
		@password = p
	end

	def config_set_up
		#Make sure the the config directory is created
		unless Dir.exists?(File.join(File.dirname(__FILE__),"configuration"))
			FileUtils.mkdir_p(File.join(File.dirname(__FILE__),"configuration"))
		end	
		#Make sure the the config file is created withing the configuration directory
		unless File.exists?(File.join(File.dirname(__FILE__),"configuration","config.yml"))
			File.new(File.join(File.dirname(__FILE__),"configuration","config.yml"), File::CREAT)
		end		
	end

	def create_token #Runs FIRST
		
		get_credentials()
		uri = URI.parse(@token_endpoint)
		token_creation_data = '{"name" : "ruby-integration"}'

		response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
			request = Net::HTTP::Post.new(uri.request_uri,'Content-Type' => 'application/json') 
			request.basic_auth(@username,@password)
			request.body = token_creation_data
			http.request(request)
		end
		
		if response.kind_of? Net::HTTPSuccess 
			@token[:id] = JSON.parse(response.body)['id'].to_s
			@token[:value] = JSON.parse(response.body)['token'].to_s
			puts 'Token created successfully!'
			create_signature()
		elsif response.kind_of? Net::HTTPRedirection 
			location = response['location']
			warn "Warning: Redirected to #{location}"
			#return false
		elsif response.kind_of? Net::HTTPUnauthorized 
			warn "Error: #{response.message}: invalid credentials.\n\n"
			create_token()
		elsif response.kind_of? Net::HTTPServerError 
			warn "Error: #{response.message}: try again later."
			exit
		else
			warn "Error: #{response.message}"
			exit
		end
	end

	def create_signature #Runs SECOND
		@http_date = DateTime.now.httpdate
		string_to_sign = @user_agent + @http_date
		digest = OpenSSL::Digest.new('sha1')
		hmac_string = OpenSSL::HMAC.digest(digest, @token[:value], string_to_sign).to_s
		@signature = Base64.encode64(hmac_string).chomp
		sleep (1) #DateTime.now.httpdate uses seconds as its smallest counter unit. 
				  #Prevents Auth error when making successive request using
				  #the signature 
	end

	def token_valid?
		
		key_id =  @token[:id]
		uri = URI.parse(@uri + '/Headers') #'https://se1.openasset.com/REST/1/Headers'

		create_signature()
		
		token_auth_string = "OAT #{key_id}:#{@signature}" 	
		#puts "auth_string val: #{token_auth_string}"
	
		response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
			request = Net::HTTP::Get.new(uri.request_uri,{'User-Agent' => @user_agent})
			request['Authorization'] = token_auth_string #By using the signature, you indirectly check if token is valid
			request['X-Date'] = @http_date
			http.request(request)
		end
		
		if response.kind_of? Net::HTTPSuccess
			#if the token is valid then we can grab the session key for our requests
			puts "Valid Token detected...Acquiring session."
			@session_key = response['X-SessionKey']
			store_session_data(@session_key, @token[:value], @token[:id])
			return true
		elsif response.kind_of? Net::HTTPRedirection 
			location = response['location']
			warn "Warning: Redirected to #{location}"
			return false
		elsif response.kind_of? Net::HTTPUnauthorized 
			warn "Error: #{response.message}" 
			return false
		elsif response.kind_of? Net::HTTPServerError 
			warn "Error: #{response.message}: try again later."
			return false
		else
			warn "Error: #{response.message}"
			return false
		end
		 
	end

	def validate_token #for code readability
		token_valid?
	end

	def setup_authentication
		#puts "In setup_authentication"
		 if @token[:id].nil?
			#puts "Token is NULL"
		 	create_token()
		 	validate_token()
		 elsif !token_valid?     
		 	puts "Invalid token!"
		 	create_token()
		 	validate_token()
		 else
		 	warn "Unknown Error: Authentication setup failure."
		 	exit!
		 end
	end

	def session_valid?
		uri = URI.parse(@uri + '/Headers')
		response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
			request = Net::HTTP::Get.new(uri.request_uri)
			request.add_field('X-SessionKey',@session_key)
			http.request(request)
		end
		#puts "In session_valid? - after req"
		case response
		    when Net::HTTPSuccess
		    	puts "Session validated!"
				return true
		    else
		        warn "Error: #{response.message} - Invalid Session"
		        return false
		 end
	end

	def store_session_data(session,token,token_id)

		enc_session_key = Security::encrypt(session)
		enc_token       = Security::encrypt(token)

		yml_file = File.join(File.dirname(__FILE__),"configuration","config.yml")
		
		conf = YAML::load_file(yml_file) || Hash.new
		url = URI.parse(@url).host #get url w/o protocol

		if conf.nil?
			puts "Looks like you messed with the config yaml file and saved it with\n " +
				"whitespace characters in the beginning. Bailing."
			exit!
		end

		if conf[url].nil?
			conf[url]      = Hash.new
			conf[url]['t'] = enc_token
			conf[url]['s'] = enc_session_key
			conf[url]['i'] = token_id.to_s
		else 
			conf[url]['t'] = enc_token
			conf[url]['s'] = enc_session_key
			conf[url]['i'] = token_id.to_s
		end	

		File.open(yml_file,"w+") do |file|
			puts "Writing to config file."
			file.write(conf.to_yaml)
			puts "Done. Session data stored"
		end
	end

	def retrieve_session_data
		
		yml_file = File.join(File.dirname(__FILE__),"configuration","config.yml")
		
		conf = YAML::load_file(yml_file)
		url = URI.parse(@url).host #get url w/o protocol
		#puts conf
		unless conf
			warn "Empty config file: No session data found."
			return
		end
		
		if !conf[url].nil?
			#retrieve base64 encoded values
			token_id   	     = conf[url]['i']
			enc_token        = conf[url]['t']
			enc_session_key  = conf[url]['s']
		
			#decrypt and assign data to instance variable if cipher data successfully retrieved
			#USE TRY CATCH BLOCK HERE
			begin
				@session_key   = Security::decrypt(enc_session_key)
				@token[:value] = Security::decrypt(enc_token)
				@token[:id]    = token_id
			rescue Exception => e
				warn "Error: Unable to decrypt stored session data. Possibly due to hostname change or destroyed session.\n#{e.message} "
			end	
		else
			puts "No Client data found."
			return
		end	
	end

	public
	def self.get_instance(url)
		self.new(url)
	end
	def get_session
		config_set_up()
		retrieve_session_data()
		#puts @session_key || "empty session_key"  #For debugging
		
		if @session_key == 'INVALIDATED SESSION KEY'     #check for session manually invalidated by the user NOT DUE TO EXPIRY 
			validate_token()             # <- this method renews the session
		elsif  @session_key.nil?         #check for uninitialized session -> @session = nil
			setup_authentication()
		elsif !session_valid?			 #check for exired session
		 	validate_token()
		else
			puts "Retrieved stored session."
		end
		@session_key
	end

    def kill_session
		@session_key = 'INVALIDATED SESSION KEY'
		
		enc_session_key = Security::encrypt(@session_key)

		#Load and edit the data from the yaml config file
		yml_file = File.join(Dir.pwd,"configuration","config.yml")
		conf = YAML::load_file(yml_file)

		#return if there is no session to edit
		unless conf
			puts "Conf file is empty. No session to destroy."
			return
		end

		url = URI.parse(@url).host #get url w/o protocol

		if conf[url].nil?
			puts "No Entry for #{url} found. No session to destroy."
			return
		elsif conf.has_key?(url) && conf[url].has_key?('s')
			#conf[url]['token'] = enc_token
			conf[url]['s']  = enc_session_key

		else
			warn "An unknown error happened while trying to kill the session."
			return
		end	
		#write it out to the config file
		File.open(yml_file,"w") do |file|
			puts "Writing to config file."
			file.write(conf.to_yaml)
			puts "Done. Session destroyed"
		end	
		
    end    
end
