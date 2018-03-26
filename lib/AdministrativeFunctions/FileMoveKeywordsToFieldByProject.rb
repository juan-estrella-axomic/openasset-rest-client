module FileMoveKeywordsToFieldByProject

	def __move_file_keywords_to_field_by_project(project,
                                                 keyword_category,
                                                 target_field,
                                                 field_separator,
                                                 insert_mode=nil,
                                                 batch_size=200)
        # Validate input
        args = process_field_to_keyword_move_args('projects',
                                                  project,
                                                  keyword_category,
                                                  target_field,
                                                  field_separator,
                                                  batch_size,
                                                  true)

        file_keyword_categories_found = 
            (args.target_keyword_category.is_a?(Array)) ? args.target_keyword_category : [args.target_keyword_category]
        project_found                 = args.container
        target_field_found            = args.source_field

        file_keyword_category_ids     = nil
        built_in                      = nil
        file_ids                      = nil
        keywords                      = []
        files                         = []
        total_file_count              = 0
        total_files_updated           = 0  # For better readability
        offset                        = 0
        iterations                    = 0
        limit                         = batch_size.to_i.abs
        op                            = RestOptions.new

        # Validate insert mode and warn user of restricted field type
        if RESTRICTED_LIST_FIELD_TYPES.include?(target_field_found.field_display_type)
            answer = nil
            error  = "\nInvalid input. Please enter \"yes\" or \"no\".\n> "
            message = "Warning: You are inserting keywords into a restricted field type. " +
                      "\n     Project keywords are sorted in alphabetical order. " +
                      "\n     All file keywords will be created as options but only the first one will be displayed in the field." +
                      "\nContinue? (Yes/no)\n> "

            print message

            while answer != 'yes' && answer != 'no'

                print error unless answer.nil?

                answer = gets.chomp.to_s.downcase

                abort("You entered #{answer.inspect}. Exiting.\n\n") if answer.downcase == 'no' || answer == 'n'

                break if answer == 'yes' || answer == 'y'

            end          
        
        end

        unless ['append','overwrite'].include?(insert_mode.to_s)
            msg = "Argument Error: Expected \"append\" or \"overwrite\" for fourth argument \"insert_mode\" in #{__callee__}. " +
                  "Instead got #{insert_mode.inspect}"
            logger.error(msg)
            abort
        end

        # Check the source_field field type
        built_in = (target_field_found.built_in == '1') ? true : false

        # Get keywords
        msg = "Retrieving keywords for keyword category => #{file_keyword_categories_found.first.name.inspect}."
        logger.info(msg.green)

        file_keyword_category_ids = file_keyword_categories_found.map(&:id).join(',')
        op.add_option('limit','0')
        op.add_option('keyword_category_id',file_keyword_category_ids)

        keywords = get_keywords(op)

        if keywords.empty?
            msg = "No keywords found in keyword category => #{file_keyword_categories_found.first.name.inspect}."
            logger.error(msg)            
            abort
        end

        op.clear
        
        # Get file ids
        msg = "Retrieving file ids in project => #{project_found.name.inspect}."
        logger.info(msg.green)
        
        op.add_option('limit','0')
        op.add_option('displayFields','id')
        op.add_option('project_id',"#{project_found.id}") # Returns files in specified project

        files = get_files(op)

        op.clear

        if files.empty?
            msg = "Project #{project_found.name.inspect} with id #{project_found.id.inspect} is empty."
            logger.error(msg)
            abort
        end

        # Extract file ids
        file_ids = files.map { |obj| obj.id.to_s }

        # Prep iterations loop
        total_file_count = file_ids.length

        msg = "Calculating batch size."
        logger.info(msg.green)

        if total_file_count % batch_size == 0
            iterations = total_file_count / batch_size
        else
            iterations = total_file_count / batch_size + 1
        end

        file_ids.each_slice(batch_size).with_index do |subset,num|

            num += 1

            msg = "Batch #{num} of #{iterations} => Retrieving files."
            logger.info(msg.green)     

            op.add_option('limit','0')
            op.add_option('keywords','all')
            op.add_option('fields','all')
            op.add_option('id',subset)

            # Get current batch of files
            files = get_files(op)
            op.clear
            # Move the file keywords to specified field
            move_keywords_to_fields(files,keywords,target_field_found,field_separator,insert_mode)

            # Perform file update
            msg = "Batch #{num} of #{iterations} => Attempting to perform file updates."
            logger.info(msg.white)

            run_smart_update(files,total_files_updated)

            total_files_updated += subset.length

        end

    end

end