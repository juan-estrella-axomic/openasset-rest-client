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
require_relative 'SecureString'
require_relative 'MyLogger'


#use this class to generate a token
#use http post request to get token using the authenticationToken endpoint, grab ret

#Authentication
class Authenticator

    include Logging

    AXOMIC = 'axomic'
    REQUIRED_OA_VERSION = '10.2.22'

    #@@DOMAIN_CONST = 'https://se1.openasset.com'
    @@API_CONST = '/REST'
    @@VERSION_CONST = '/1'
    @@SERVICE_CONST = '/AuthenticationTokens'

    attr_reader :uri

    private
    def initialize(url,un,pw)
        @url = Validator.validate_and_process_url(url)
        @username = un.to_s
        @password = SecureString.new(pw.to_s)
        @password.encrypt unless pw.to_s.empty?
        @openasset_version = 'Unknown'
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
        #puts "In get credentials"
        if attempts.eql?(3)
            logger.error("Too many failed login attempts.")
            abort
        end

        # Use previously entered credentials in the event of http redirect
        u = @username
        p = @password

        if token_validation_failed
            puts "TOKEN VALIDATION ERROR: Please log in again to recover.\n"
            token_validation_failed = false
        end

        while u == '' || p == ''

            if u.empty?
                puts "REMINDER: Some actions require administrative rights."
            end

            if u.empty?
                print "Enter username: "
                u=gets.strip.chomp
            end

            if p.empty?
                print "Enter password: "
                p=STDIN.noecho(&:gets).strip.chomp
            end
            puts ''
            puts "Invalid username."  if u == ''
            puts "Invalid password."  if p == ''
        end

        # Update username and password if needed
        @username = u
        @password = SecureString.new(p) unless p.is_a?(SecureString)
        @password.encrypt
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
        #puts "In create token"
        get_credentials(attempts,token_validation_failed)
        uri = URI.parse(@token_endpoint)
        token_creation_data = '{"name" : "rest-client-ruby"}'

        begin
            attempts ||= 1
            response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
                request = Net::HTTP::Post.new(uri.request_uri,{'Content-Type' => 'application/json','User-Agent' => @user_agent})
                request.basic_auth(@username,@password.decrypt)
                request.body = token_creation_data
                http.request(request)
            end
        rescue Exception => e
            if attempts.eql?(1)
                wait_and_try_again()
                attempts += 1
                retry
            end
            logger.error("Connection failed. The server is not responding. <create_token> - #{e}")
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
        sleep(1) #DateTime.now.httpdate uses seconds as its smallest counter unit.
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

       process_authentication_response(response)

    end

    def validate_token #for code readability
        #puts "validate token"
        token_valid?
    end

    def is_axomic_user?
        @username.to_s.downcase.eql?(AXOMIC) ? true : false
    end

    def get_axomic_session(attempts=0)

        get_credentials(attempts)
        uri = URI.parse(@url + @@API_CONST + @@VERSION_CONST + '/Headers') #'https://se1.openasset.com/REST/1/Headers'
        response = nil
        begin
            attempts ||= 1
            response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
                request = Net::HTTP::Get.new(uri.request_uri,{'User-Agent' => @user_agent})
                request.basic_auth(@username,@password.decrypt)
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

        process_authentication_response(response)
    end

    def process_authentication_response(response)
        success = false
        if response.kind_of? Net::HTTPSuccess
            msg = nil
            @session_key = response['X-SessionKey']
            @openasset_version = response['x-openasset-version']
            if is_axomic_user?
                msg = 'Success! You are logged in as AXOMIC.'
            else
                msg = 'Valid Token detected...Acquiring session.'
                if @openasset_version < REQUIRED_OA_VERSION
                    msg = "WARNING: Older version of OA detected! => (#{@openasset_version})\n" +
                          "Some token authentication features may not work properly.\n" +
                          "Please upgrade client to #{REQUIRED_OA_VERSION} or higher."
                end
                store_session_data(@session_key, @token[:value], @token[:id])
            end
            logger.info(msg)
            success = true
        elsif response.kind_of? Net::HTTPRedirection
            location = response['location']
            msg = "Redirected to #{location}"
            logger.warn(msg.yellow)
            uri  = URI.parse(location)  # Update the url to match the redirect
            @url = uri.scheme + '://' + uri.host
            @uri = uri.scheme + '://' + uri.host + @@API_CONST + @@VERSION_CONST
            is_axomic_user? ? get_axomic_session() : validate_token()
        elsif response.kind_of? Net::HTTPUnauthorized
            msg = "#{response.message}: Invalid Credentials.\n\n"
            logger.error(msg)
            @username = ''
            @password = ''
            get_credentials()
            if is_axomic_user?
                get_axomic_session(1)
            else
                success = false
            end
        elsif response.kind_of? Net::HTTPServerError
            msg = "Error: #{response.message}: try again later."
            logger.error(msg)
            abort
        else
            msg = "Error: #{response.message}"
            logger.error(msg)
            abort
        end
        success
    end

    def setup_authentication
        #puts "In setup authentication"
        if is_axomic_user?
            get_axomic_session()
        else
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
    end

    def session_valid?
        #puts "In session valid?"
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
            logger.error("Connection failed. The server is not responding <session_valid?>. - #{e}")
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
        #puts "In store session data"

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

    def get_oa_version
        @openasset_version
    end

    def get_session
        #puts "In get session"
        if is_axomic_user?
            get_credentials() if @password.empty?
            setup_authentication()
            return @session_key
        end
        config_set_up()
        retrieve_session_data()
        #puts @session_key || "empty session_key"  #For debugging
        if @session_key == 'INVALIDATED SESSION KEY'     #check for session manually invalidated by the user NOT DUE TO EXPIRY
            unless token_valid?             # <- this method renews the session
                setup_authentication()
            end
        elsif  @session_key.nil?         #check for uninitialized session -> @session = nil
            #puts "session key nil"
            setup_authentication()
        elsif !session_valid?             #check for expired session
            #puts "session key invalid"
            if !token_valid?
                puts "token invalid"
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
