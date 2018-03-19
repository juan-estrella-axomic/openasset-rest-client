require 'csv'
require 'openssl'
require 'base64'
require 'socket'
require 'fileutils'
require 'date'
require 'colorize'

require_relative 'Authenticator'
require_relative 'Downloader'
require_relative 'Nouns/Files'
require_relative 'MyLogger'

module CSVHelper
    
    # Generate csv reports from Noun collections. Call on an array of Files Objects, Strings or Array of Strings
    #
    # @param client [String, Integer] Name of the csv being generated
    # @return [Boolean] Returns false on error.
    # 
    # @example
    #       projects = rest_client.get_projects()
    #       projects.export_to_csv('SE1')
    #       -- ONE LINER --
    #       rest_client.get_projects().export_to_csv('SE1') 
    def export_to_csv(client=nil)
        name = client.to_s || 'Client_Name'
        object_variables = nil
        noun = nil
        #check if the collection is emplty
        if self.empty?
            msg = "Oops. There are no items in the collection. " +
                  "No use in creating spreadsheet."
            Logging::logger.warn(msg.yellow)
            return
        end
       
        #processs the objects to extract the headers and rows for csv report
        #get the instance variables of the first object we will use it to
        #build the headers of the csv file and to retieve the values of the object

        #Notes -> instance variables must be initialized to at least nil
        #in order for the instance_variables method to work
        if Validator::NOUNS.include?(self.first.class.to_s) #its a NOUN
            noun = true
            object_variables = self.first.instance_variables #returns an array
        end

        #Create csv file using the clients subdomain name and insert the headers
        filename = name + '_CSV_Export_' + Time.new.strftime("%Y%m%d%H%M%S") + '.csv'

        CSV.open(filename, "w") do |csv|
            if noun
                object = self.first || abort('Error: Collection is empty.')

                #Create csv header and filter out nested resources
                csv_header = object_variables.map do |obj_var|
                    unless object.instance_variable_get(obj_var).is_a?(Array)                  
                         obj_var.to_s.gsub('@','').upcase.encode!("UTF-8", invalid: :replace, undef: :replace)
                    end 
                end 
             
                csv << csv_header
              
                #loop through each of the NOUN objects
                self.each do |noun_obj|
                    abort("noun_obj is nil") unless noun_obj
                    csv_values = Array.new
                    
                    #loop through the object variables
                    csv_header.each do |variable_name|
                        
                        #build the line to be inserted into csv file by
                        if variable_name
                            data = noun_obj.instance_variable_get('@' + variable_name.downcase)
                            #we only want built in attributes
                            unless data.is_a?(Array)
                                csv_values << data.to_s.encode!("UTF-8", invalid: :replace, undef: :replace)
                            end
                        end
                        
                    end

                    #write values to the spreadsheet
                    csv << csv_values
                end
            elsif self.first.is_a?(String)
                #loop through each of the strings
                self.each do |str|
                    #write values to the spreadsheet
                    str = str.to_s.encode!("UTF-8", invalid: :replace, undef: :replace)
                    csv << [str]
                end
            elsif self.first.is_a?(Array)
                self.each do |arr|
                    #write values to the spreadsheet
                    arr.each { |val| val.to_s.encode!("UTF-8", invalid: :replace, undef: :replace) }
                    csv << arr
                end
            else
                msg = "Oops. Items in the collection are #{self.first.class.to_s} " + 
                      "instead of NOUN objects or Strings."
                Logging::logger.error(msg.red)
                return
            end
        end
    end
end

module DownloadHelper
    # Downloads actual image from Files Object, Array of Files Objects, or a list of urls.
    #
    # @param size [String, Integer] Defaults to 1 to download original image.
    #                               Accepts image size id or postfix string value like 'medium' for example
    # @param download_location [String] Folder where files will be downloaded to.
    # @return [Boolean] Returns false on error.
    # 
    # @example
    #       files_obj_array = rest_client.get_files()
    #       files_obj_array.download('medium','se1_downloads')
    #       -- ONE LINER --
    #       rest_client.get_files().download('medium','se1_downloads') 
    def download(size='1',download_location='./Rest_Downloads')
        #Make sure the download location is Valid directory
        if File.exist?(download_location)
            unless File.directory?(download_location)
                msg = "The download location provided is not a directory."
                Logging::logger.error(msg.red)
                return false
            end
        else
            msg = "Creating Directory => #{download_location}"
            Logging::logger.info(msg)
            download_location = download_location + '_' + DateTime.now.strftime("%Y%m%d%H%M%S")
            FileUtils::mkdir_p download_location
            FileUtils.chmod(0777, download_location, :verbose => false)
        end

        if self.empty?
            msg = "Oops. The collection is empty. There are no Files to download."
            Logging::logger.warn(msg.yellow)
            return false
        end 

        unless self.first.is_a?(Files) || self.first.is_a?(String)
            msg = "Error: 'download' method requires that the array only contains " +
                  "Files NOUN objects or url strings."
            Logging::logger.error(msg.red)
            return false
        end
        
        #loop through objects in the Array
        self.each do |item|
            if item.is_a?(Files)
                file_path = item.get_image_size_file_path(size)
                next unless file_path # Skip file if the size hasn't been created
                url = "https://" + file_path         
                uri = URI.parse(url)
                filename = url.split('/').last
                location = download_location + '/' + filename 
                Downloader::download(uri,location)
            elsif item.is_a?(String) && item.include?('openasset.com')
                #remove white space and new line characters
                url = item.chomp.strip
                uri_with_protocol = Regexp::new('(^https:\/\/|http:\/\/)\w+.+\w+.openasset.com', true)
                #check if uri scheme is specified and
                unless (uri_with_protocol =~ url) == 0 #starting position of regex string
                    url = "https://" + url 
                end
                uri = URI.parse(url) #for the http request in the downloader
                filename = url.split('/').last  
                location = download_location + '/' + filename
                Downloader::download(uri,location)
            elsif item.is_a?(String) #for non OpenAsset downloads
                #remove white space and new line characters
                url = item.chomp.strip
                url_with_http = Regexp::new('(^https:\/\/|http:\/\/)', true)
                #check if uri scheme is specified and
                unless (url_with_http =~ url) == 0 #starting position of regex string
                    url = "http://" + url 
                end
                filename = url.split('/').last  
                location = download_location + '/' + filename
                begin
                    Downloader::download(uri,location)
                rescue => exception
                    Logging::logger.error("#{exception.message}".red)
                end
            else
                puts "Error: Invalid data detected in the array.\nValue => #{item.inspect}"
            end
        end
        FileUtils.remove_dir(download_location)  if Dir["#{download_location}/*"].empty?
    end
end
