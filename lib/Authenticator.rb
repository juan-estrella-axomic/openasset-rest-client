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
require 'colorize'
require 'yaml'  #for storing data locally


require_relative 'ArrayHelpers'
require_relative 'Validator'
require_relative 'Security'
require_relative 'MyLogger'


#use this class to generate a token
#use http post request to get token using the authenticationToken endpoint, grab ret

#Authentication
class Authenticator

    include Logging

    #@@DOMAIN_CONST = 'https://se1.openasset.com'
    @@API_CONST = '/REST'
    @@VERSION_CONST = '/1'
    @@SERVICE_CONST = '/AuthenticationTokens'

    attr_reader :uri

    private
    def initialize(url,un,pw)
        @url = Validator.validate_and_process_url(url)
        @username = un.to_s
        @password = pw.to_s
        @uri = @url + @@API_CONST + @@VERSION_CONST
        @token_endpoint = @url + @@API_CONST + @@VERSION_CONST + @@SERVICE_CONST
        @token = {:id => nil, :value => nil}
        @session_key = nil
        @http_date = nil
        @user_agent = 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0'
        @signature = ''
    end

    def wait_and_try_again
        logger.warn("Initial Connection failed. Retrying in 15 seconds.")
        15.times do |num|
            printf("\rRetrying in %-2.0d",(15-num)) 
            sleep(1)
        end
        printf("\rRetrying NOW        \n")
        logger.warn("Re-attempting request. Please wait.")
    end

    def get_credentials(attempts=0,token_validation_failed=false)

        if attempts.eql?(3) 
            logger.error("Too many failed login attempts.")
            abort
        end

        # Use previously enterd credentials in the event of http redirect
        u = @username
        p = @password

        while u == '' || p == '' || token_validation_failed
            if u.empty?
                puts "REMINDER: Some actions require administrative rights."
            elsif token_validation_failed
                puts "TOKEN VALIDATION ERROR: Please log in again to recover."
                token_validation_failed = false
            end

            print "Enter username: "
            u=gets.strip.chomp

            print "Enter password: "
            p=STDIN.noecho(&:gets).strip.chomp
            puts ''
            puts "Invalid username."  if u == ''
            puts "Invalid password."  if p == ''
        end

        # Update username and password if needed
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

    def create_token(attempts=0,token_validation_failed=false) #Runs FIRST
        
        get_credentials(attempts,token_validation_failed)
        uri = URI.parse(@token_endpoint)
        token_creation_data = '{"name" : "rest-client-ruby"}'
       
        begin
            attempts ||= 1
            response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
                request = Net::HTTP::Post.new(uri.request_uri,{'Content-Type' => 'application/json','User-Agent' => @user_agent}) 
                request.basic_auth(@username,@password)
                request.body = token_creation_data        
                http.request(request)  
            end
        rescue Exception => e 
            if attempts.eql?(1)
                wait_and_try_again()
                attempts += 1
                retry                
            end
            logger.error("Connection failed. The server is not responding. - #{e}")
            exit(-1)
        end
        
        if response.kind_of? Net::HTTPSuccess
            begin 
                @token[:id] = JSON.parse(response.body)['id'].to_s
                @token[:value] = JSON.parse(response.body)['token'].to_s
            rescue JSON::ParserError => e
                logger.error("JSON Parser Error: #{e.message}")
                exit(-1)
            end
            # It's an On-Prem Codebase! No token was returned even though the authentication was successful!
            if @token[:id].to_s.empty? || @token[:value].to_s.empty?
                msg = 'It looks like you are using an outdated On-premise codebase. OpenAsset Cloud codebase 10.3.12 or higher required.'
                logger.error(msg.yellow)
                exit(-1)
            end
            msg = 'Token created successfully!'
            logger.info(msg)
            create_signature()
        elsif response.kind_of? Net::HTTPRedirection 
            location = response['location']
            msg = "Redirected to #{location}"
            logger.warn(msg.yellow)
            @token_endpoint = location
            uri  = URI.parse(location)  # Update the url to match the redirect
            @url = uri.scheme + '://' + uri.host
            @uri = uri.scheme + '://' + uri.host + @@API_CONST + @@VERSION_CONST
            create_token()
        elsif response.kind_of? Net::HTTPUnauthorized 
            msg = "#{response.message}: Invalid Credentials.\n\n"
            logger.error(msg)
            @username = ''
            @password = ''
            create_token(attempts + 1)
        elsif response.kind_of? Net::HTTPServerError 
            msg = "Error: #{response.message}: try again later."
            logger.error(msg)
            abort
        else
            msg = "Error: #{response.message}"
            logger.error(msg)
            abort
        end
        return true
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
        uri = URI.parse(@url + @@API_CONST + @@VERSION_CONST + '/Headers') #'https://se1.openasset.com/REST/1/Headers'

        create_signature()
        
        token_auth_string = "OAT #{key_id}:#{@signature}"     
        response = nil
        begin
            attempts ||= 1
            response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
                request = Net::HTTP::Get.new(uri.request_uri,{'User-Agent' => @user_agent})
                request['Authorization'] = token_auth_string #By using the signature, you indirectly check if token is valid
                request['X-Date'] = @http_date
                http.request(request) 
            end
        rescue Exception => e
            if attempts.eql?(1)
                wait_and_try_again()
                attempts += 1
                retry                
            end
            logger.error("Connection failed. The server is not responding. - #{e}")
            exit(-1)
        end
        
        if response.kind_of? Net::HTTPSuccess
            #if the token is valid then we can grab the session key for our requests
            msg = "Valid Token detected...Acquiring session."
            logger.info(msg)
            @session_key = response['X-SessionKey']
            store_session_data(@session_key, @token[:value], @token[:id])
            return true
        elsif response.kind_of? Net::HTTPRedirection 
            location = response['location']
            msg = "Redirect detected to #{location}"
            logger.warn(msg.yellow)
            uri  = URI.parse(location)  # Update the url to match the redirect
            @url = uri.scheme + '://' + uri.host
            @uri = uri.scheme + '://' + uri.host + @@API_CONST + @@VERSION_CONST
            return false
        elsif response.kind_of? Net::HTTPUnauthorized 
            msg = "#{response.message}" 
            logger.error(msg)
            #return create_token() # Returns true or program exits after 3 failed login attempts
            return false
        elsif response.kind_of? Net::HTTPServerError 
            msg = "#{response.message}: Try again later."
            logger.error(msg)
            return false
        else
            msg = "Error: #{response.message}"
            logger.error(msg)
            return false
        end
         
    end

    def validate_token #for code readability
        token_valid?
    end

    def setup_authentication
        if @token[:id].nil?
            create_token()
            validate_token()
        elsif !token_valid?     
            logger.warn("Invalid token detected!".yellow)
            create_token()
            validate_token()
        else
            msg = "Unknown Error: Authentication setup failure."
            logger.error(msg)
            abort
        end
    end

    def session_valid?
        uri = URI.parse(@uri + '/Headers')
        begin
            attempts ||= 1
            response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
                request = Net::HTTP::Get.new(uri.request_uri)
                request.add_field('X-SessionKey',@session_key)       
                http.request(request)
            end
        rescue Exception => e 
            if attempts.eql?(1)
                wait_and_try_again()
                attempts += 1
                retry                
            end
            logger.error("Connection failed. The server is not responding. - #{e}")
            exit(-1)
        end
        #puts "In session_valid? - after req"
        case response
        when Net::HTTPSuccess
            logger.info("Session validated!")
            return true
        else
            msg = "Invalid session detected. Renewing."
            logger.warn(msg.yellow)
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
            msg = "Looks like the configuration file has been altered or become corrupted. Aborting."
            logger.error(msg)
            abort
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
            logger.info("Updating configuration file data.")
            file.write(conf.to_yaml)
            logger.info("Done. Successfully stored session data".green)
        end
    end

    def retrieve_session_data
        
        yml_file = File.join(File.dirname(__FILE__),"configuration","config.yml")
        
        conf = YAML::load_file(yml_file)
        url = URI.parse(@url).host #get url w/o protocol
        #puts conf
        unless conf
            msg = "Empty config file: No session data found."
            logger.warn(msg.yellow)
            return
        end
        
        unless conf[url].nil?
            #retrieve base64 encoded values
            token_id         = conf[url]['i']
            enc_token        = conf[url]['t']
            enc_session_key  = conf[url]['s']
        
            #decrypt and assign data to instance variable if cipher data successfully retrieved
            #USE TRY CATCH BLOCK HERE
            begin
                @session_key   = Security::decrypt(enc_session_key)
                @token[:value] = Security::decrypt(enc_token)
                @token[:id]    = token_id
            rescue Exception
                msg = "Unable to retrieve stored session data."
                logger.warn(msg.yellow)
            end    
        else
            msg = "No client session data found."
            logger.info(msg)
            return
        end    
    end

    public
    def self.get_instance(url,un,pw)
        self.new(url,un,pw)
    end

    def get_session
        config_set_up()
        retrieve_session_data()
        #puts @session_key || "empty session_key"  #For debugging
        
        if @session_key == 'INVALIDATED SESSION KEY'     #check for session manually invalidated by the user NOT DUE TO EXPIRY 
            unless token_valid?             # <- this method renews the session
                setup_authentication()
            end
        elsif  @session_key.nil?         #check for uninitialized session -> @session = nil
            setup_authentication()
        elsif !session_valid?             #check for expired session
            if !token_valid?
                create_token(0,true)     # seeds the number of login attempts for get_credentials() "0" and sets the failed token validation flag
                validate_token()
            end
        else
            logger.info("Retrieved stored session.")
        end
        @session_key
    end

    def kill_session

        if @session_key.eql?('INVALIDATED SESSION KEY')
           msg = "Session already invalidated."
           logger.info(msg)
           return
        end

        @session_key = 'INVALIDATED SESSION KEY'
        
        enc_session_key = Security::encrypt(@session_key)

        #Load and edit the data from the yaml config file
        yml_file = File.join(File.dirname(__FILE__),"configuration","config.yml")
        conf = YAML::load_file(yml_file)

        #return if there is no session to edit
        unless conf
            logger.info( "Conf file is empty. No session to destroy.")
            return
        end

        url = URI.parse(@url).host #get url w/o protocol

        if conf[url].nil?
            msg = "No Entry for #{url} found. No session to destroy."
            logger.info(msg)
            return
        elsif conf.has_key?(url) && conf[url].has_key?('s')
            #conf[url]['token'] = enc_token
            conf[url]['s']  = enc_session_key

        else
            msg = "An unknown error happened while trying to kill the session."
            logger.error(msg)
            return
        end    
        #write it out to the config file
        File.open(yml_file,"w") do |file|
            logger.info("Updating configuration data.")
            file.write(conf.to_yaml)
            logger.info("Done. Session destroyed.")
        end    
        @session_key
    end    
end
