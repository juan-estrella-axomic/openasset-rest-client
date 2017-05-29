require 'csv'
require 'openssl'
require 'base64'
require 'socket'
require 'fileutils'
require 'date'

require_relative 'Authenticator.rb'
require_relative 'Downloader.rb'
require_relative 'Nouns/Files.rb'

module ArrayHelper
    
    # #generate csv reports from Noun collections. Call on an array of Files Objects, Strings or Array of Strings
    #
    # @param client [String, Integer] Name of the csv being generated
    # @return [Boolean] Returns false on error.  
    def export_to_csv(client=nil)
        name = client.to_s || 'Client_Name'
        #check if the collection is emplty
        if self.empty?
            warn "Oops. There are no items in the collection. No use in creating spreadsheet."
            return false
        end
       
        #processs the objects to extract the headers and rows for csv report
        #get the instance variables of the first object we will use it to
        #build the headers of the csv file and to retieve the values of the object
        
        object_variables = self.first.instance_variables.collect(&:itself)

        #Create csv file using the clients subdomain name and insert the headers
        filename = name + '_CSV_Export_' + Time.new.strftime("%Y%m%d%H%M%S") + '.csv'
        puts filename.inspect
        #csv_file = File.new(filename, File::CREAT)

        CSV.open(filename, "w") do |csv|
            if Validator::NOUNS.include?(self.first.class.to_s) #its a NOUN
                csv_header = object_variables.map {|val| val.to_s.gsub('@','').upcase}
                csv << csv_header
                #loop through each of the NOUN objects
                self.each do |noun_obj|
                    csv_values = Array.new
                    #loop through the object variables
                    object_variables.each do |var|
                        #build the array of values
                        #use the noun_obj to access it values
                        csv_values << (noun_obj.instance_variable_get(var)).to_s
                    end
                    #write values to the spreadsheet
                    csv << csv_values
                end
            elsif self.first.is_a?(String)
                #loop through each of the strings
                self.each do |str|
                    #write values to the spreadsheet
                    csv << [str]
                end
            elsif self.first.is_a?(Array) && self.first.first.is_a?(String)
                self.each do |arr|
                    #write values to the spreadsheet
                    csv << arr
                end
            else
                 warn "Oops. Items in the collection are #{self.first.class.to_s} " + 
                 "instead of NOUN objects, Strings, or arrays of Strings"
                 return false
            end
        end
    end

    # Downloads actual image from Files Object using nested Sizes resource. Call on an array of Files Objects
    #
    # @param size [String, Integer] Defaults to 1 to download original image.
    #                               Accepts image size id or postfix string value like 'medium' for example
    # @param download_location [String] Folder where files will be downloaded to.
    # @return [Boolean] Returns false on error.  
    def download(size='1',download_location='./Rest_Downloads')
        #Make sure the download location is Valid directory
        if File.exist?(download_location)
            unless File.directory?(download_location)
                puts "Argument Error: The download location provided is invalid."
                return false
            end
        else
            puts "Creating Directory => #{download_location}."
            download_location = download_location + '_' + DateTime.now.strftime("%Y%m%d%H%M%S")
            FileUtils::mkdir_p download_location
        end

        if self.empty?
            puts "Oops. The array is empty. There are no Files to download."
            return false
        end 

        unless self.first.is_a?(Files) || self.first.is_a?(String)
            puts "Error: 'download' method requires the the array only contains " +
                 "Files NOUN objects or url strings."
            return false
        end
        
        #loop through objects in the Array
        self.each do |item|
            #remove white space and new line characters
            item.chomp!.strip!
            if item.is_a?(Files)
                url = "https://" + item.get_image_size_file_path(size)          
                uri = URI.parse(url)
                filename = url.split('/').last
                location = download_location + '/' + filename 
                Downloader::download(uri,location)
            elsif item.is_a?(String) && item.include?('openasset.com')
                url = item
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
                url = item
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
                    puts "Error: #{exception.message}"
                end
            else
                puts "Error: Invalid data detected in the array.\nValue => #{item.inspect}"
            end
        end
        FileUtils.remove_dir(download_location)  if Dir["#{download_location}/*"].empty?
    end
end