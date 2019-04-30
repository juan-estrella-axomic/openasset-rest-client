require_relative 'Validator'
require_relative 'ObjectGenerator'

module FileUploader

    def __upload_file(file,category,project,generate_objects,read_timeout,low_priority_processing)

        query   = low_priority_processing ? '?lowPriority=1' : ''
        timeout = read_timeout.to_i.abs
        timeout = timeout > 0 ? timeout : 120 # 120 sec is the default
        tries   = 1
        response = nil

        unless File.exist?(file.to_s)
            msg = "The file #{file.inspect} does not exist...Bailing out."
            logger.error(msg)
            return false
        end

        unless category.is_a?(Categories) || category.to_i > 0
            msg = "Argument Error for upload_files method: Invalid category id passed to second argument.\n" +
                  "Acceptable arguments: Category object, a non-zero numeric String or Integer, " +
                  "or no argument.\nInstead got #{category.class}...Bailing out."
            logger.error(msg)
            return false
        end

        unless project.is_a?(Projects) || project.to_i > 0 || project.to_s.strip.eql?('')
            msg = "Argument Error for upload_files method: Invalid project id passed to third argument.\n" +
                  "Acceptable arguments: Projects object, a non-zero numeric String or Integer, " +
                  "or no argument.\nInstead got a(n) #{project.class} with value => #{project.inspect}...Bailing out."
                  logger.error(msg)
            return false
        end

        category_id = category.is_a?(Categories) ? category.id : category
        project_id  = if project.is_a?(Projects)
                        project.id
                      elsif project.nil?
                        ''
                      else
                        project
                      end

        uri = URI.parse(@uri + '/Files' + query)
        boundary = (0...50).map { rand(65..90).chr }.join #genererate a random str thats 50 char long
        body = []

        msg = "Uploading File: => {\"original_filename\":\"#{File.basename(file)}\",\"category_id\":\"#{category_id}\",\"project_id\":\"#{project_id}\"}"
        logger.info(msg.white)

        # upload waits up to 15 sec to complete before timing out
        loop do
            begin
                attempts ||= 1
                response = Net::HTTP.start(uri.host, uri.port, :read_timeout => timeout, :use_ssl => uri.scheme == 'https') do |http|
                    request = Net::HTTP::Post.new(uri.request_uri)

                    if @session
                        request.add_field('X-SessionKey',@session)
                    else
                        @session = @authenticator.get_session
                        request.add_field('X-SessionKey',@session)
                    end

                    raw_filename = File.basename(file)
                    encoding = raw_filename.encoding.to_s

                    begin
                        filename = raw_filename.force_encoding(encoding).encode(@outgoing_encoding, # Default UTF-8
                                                                                encoding,
                                                                                invalid: :replace,
                                                                                undef: :replace,
                                                                                replace: '?') # Read string as identifed encoding and convert to utf-8
                    rescue Exception => e
                        logger.error("Problem converting filename \"#{raw_filename}\" to UTF-8. Error => #{e.message}")
                        return
                    end

                    filename.scrub!('') # Replaces bad bytes with a ''

                    request["cache-control"] = 'no-cache'
                    request["content-type"] = 'multipart/form-data; boundary=----WebKitFormBoundary' + boundary
                    body << "------WebKitFormBoundary#{boundary}\r\nContent-Disposition: form-data; name=\"_jsonBody\""
                    body << "\r\n\r\n[{\"original_filename\":\"#{filename}\",\"category_id\":#{category_id},\"project_id\":\"#{project_id}\"}]\r\n"
                    body << "------WebKitFormBoundary#{boundary}\r\nContent-Disposition: form-data; name=\"file\";"
                    body << "filename=\"#{filename}\"\r\nContent-Type: #{MIME::Types.type_for(file)}\r\n\r\n"
                    body << IO.binread(file)
                    body << "\r\n------WebKitFormBoundary#{boundary}--"
                    request.body = body.join
                    http.request(request)
                end
            rescue StandardError => e

                logger.warn("Initial Connection failed. Retrying in 20 seconds.") if attempts.eql?(1)
                msg = e.message
                if attempts.eql?(1)
                    20.times do |num|
                        printf("\rRetrying in %-2.0d",(20-num))
                        sleep(1)
                    end
                    attempts += 1
                    retry
                end
                if msg.include?("incompatible character encodings")
                    # This means a bad character was found in the file path
                    msg += ". Check file path in the spreadsheet for bad characters." +
                           "\nReplace the bad characters in the spreadsheet and file system. "
                end
                logger.error("Connection failed: #{msg}")
                Thread.current.exit
            end

            if response.body.include?('<title>OpenAsset - Something went wrong!</title>') && response.code != '403'
                response.body = {
                    'error_message' => 'Possible Gateway timeout: NGINX Error - OpenAsset - Something went wrong!',
                    'http_status_code' => response.code.to_s
                }.to_json
                if tries < 3
                    tries += 1
                    logger.error("Apache fell behind and NGINX is returning it's infamous error. Waiting 30 seconds before trying again.")
                    sleep(30)
                    redo
                else
                    logger.error("Made 3 failed attempts. Apache may be down or took way too long to respond. (NGINX ERROR PAGE RETURNED)")
                end
            end

            response = Validator.process_http_response(response,@verbose,'Files','POST')
            break
        end

        if generate_objects

            data = Files.new
            data.id = 'n/a'
            data.filename = File.basename(file)

            res = process_errors(data,response,'Files','Create')

            generate_objects_from_json_response_body(res,'Files')

        else
            # JSON Object
            response
        end
    end
end