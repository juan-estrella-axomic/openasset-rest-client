require_relative 'Validator'
require_relative 'ObjectGenerator'

module FileReplacer

	def __replace_file(original_file_object=nil, 
                     replacement_file_path='', 
                     retain_original_filename_in_oa=false, 
                     generate_objects=false) 

        file_object = (original_file_object.is_a?(Array)) ? original_file_object.first : original_file_object
        uri = URI.parse(@uri + "/Files")
        id = file_object.id.to_s
        original_filename = nil

        # raise an Error if something other than an file object is passed in. Check the class
        unless file_object.is_a?(Files) 
            msg = "Argument Error: First argument => Invalid object type! Expected File object" +
                  " and got #{file_obj.class} object instead. Aborting update."
            logger.error(msg)
            return
        end
        
        if File.directory?(replacement_file_path)
            msg = "Argument Error: Second argument => Expected a file! " +
                  "#{replacement_file_path} is a directory! Aborting update."
            logger.error(msg)
            return
        end


        #check if the replacement file exists
        unless File.exists?(replacement_file_path) && File.file?(replacement_file_path)
            msg = "The file #{replacement_file_path} does not exist. Aborting update."
            logger.error(msg)
            return
        end

        #verify that both files have the same file extentions otherwise you will
        #get a 400 Bad Request Error
        if File.extname(file_object.original_filename) != File.extname(replacement_file_path)
            msg = "File extensions must match! Aborting update\n    " + 
                  "Original file extension => #{File.extname(file_object.original_filename)}\n    " +
                  "Replacement file extension => #{File.extname(replacement_file_path)}"
            logger.error(msg)
            return
        end

        #verify that the original file id is provided
        unless id.to_s != "0"
            msg = "Invalid target file id! Aborting update."
            logger.error(msg)
            return
        end

        #change in format
        if retain_original_filename_in_oa == true
            unless file_object.original_filename == nil || file_object.original_filename == ''

                original_filename = File.basename(file_object.original_filename)
            else
                msg = "No original filename detected in Files object. Aborting update."
                logger.error(msg)
                return
            end
        else
            original_filename = File.basename(replacement_file_path)
        end

        raw_filename = original_filename
        encoding = raw_filename.encoding.to_s
        
        begin
            original_filename = raw_filename.force_encoding(encoding).encode(@outgoing_encoding, # Default UTF-8 
		                                                                    encoding, 
		                                                                    invalid: :replace, 
		                                                                    undef: :replace, 
		                                                                    replace: '?') # Read string as identifed encoding and convert to utf-8
        rescue Exception => e
            logger.error("Problem converting filename \"#{raw_filename}\" to UTF-8. Error => #{e.message}")
            return
        end 

        filename.scrub!('') # Replaces bad bytes with a ''

        body = Array.new

        begin
            attempts ||= 1
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
        rescue Exception => e
            
            logger.warn("Initial Connection failed. Retrying in 15 seconds.") if attempts.eql?(1)
            if attempts.eql?(1)
                180.times do |num|
                    printf("\rRetrying in %-2.0d seconds",(180-num)) 
                    sleep(1)
                end
                attempts += 1
                retry
            end
            if e.message.include?("incompatible character encodings")
                # This means a bad character was found in the file path
                e.message += ". Check file path in the spreadsheet and compare it with the file system."
            end
            logger.error("Connection failed: #{e}")
            Thread.current.exit
        end

        Validator.process_http_response(response,@verbose,'Files', 'PUT')

        if generate_objects
            
            generate_objects_from_json_response_body(response,'Files')

        else
            # JSON Object
            response
        end
            
    end
end