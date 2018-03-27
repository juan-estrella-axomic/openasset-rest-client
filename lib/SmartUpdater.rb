#require_relative 'AdministrativeFunctions/ConnectionTester'

module SmartUpdater
	# @!visibility private
    def run_smart_update(payload,total_objects_updated)

        scope    = payload.first.class.to_s.downcase
        res      = nil
        attempts = 0
        results_count = 0

        # Perform the update => 3 tries MAX with 5,10,15 second waits between retries
        loop do

            attempts += 1

            #check if the server is responding (This is a HEAD request)
            server_test_passed = get_count(Categories.new)

            # This code executes if the web server hangs or takes too long 
            # to respond after the first update is performed => Possible cause can be too large a batch size
            if attempts == 4
                Validator.process_http_response(res,@verbose,scope.capitalize,'HEAD')
                msg = "Max Number of attempts (3) reached!\nThe web server may have taken too long to respond." +
                      " Try adjusting the batch size."
                logger.error(msg)
                abort
            end

            if server_test_passed
                
                if scope == 'files'
                    res = update_files(payload,false)
                elsif scope == 'projects'
                    res = update_projects(payload,false)
                else
                    msg = "Invalid update scope. Expected Files or Projects in payload. Instead got => #{scope}"
                    logger.error(msg)
                    abort
                end
                    
                if res.kind_of? Net::HTTPSuccess
                    results_count = res['X-Full-Results-Count'].to_i
                    total_objects_updated += results_count
                    msg = ""
                    msg += "Successfully " if total_objects_updated > 0
                    msg += "Updated #{total_objects_updated.inspect} #{scope}."
                    logger.info(msg)
                    break
                else
                    Validator.process_http_response(res,@verbose,scope.capitalize,'PUT')
                    abort
                end
            else
                time_lapse = 5 * attempts
                time_lapse.times do |num|
                    print "\rWaiting for server to respond" + ("." * (num + 1))
                    sleep(1)
                end
            end
        end        
    end

    # @!visibility private
    def wait_and_try_again
        logger.warn("Initial Connection failed. Retrying in 15 seconds.")
        15.times do |num|
            printf("\rRetrying in %-2.0d",(15-num)) 
            sleep(1)
        end
        printf("\rRetrying NOW        \n")
        logger.warn("Re-attempting request. Please wait.")
    end

end