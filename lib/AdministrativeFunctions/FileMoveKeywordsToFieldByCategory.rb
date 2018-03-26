require_relative 'Constants'

module FileMoveKeywordsToFieldByCategory

    include Constants

    def __move_file_keywords_to_field_by_category(category,
	                                              keyword_category,
	                                              target_field,
	                                              field_separator,
	                                              insert_mode=nil,
	                                              batch_size=200)

        # Validate input
        args = process_field_to_keyword_move_args('categories',
                                                  category,
                                                  keyword_category,
                                                  target_field,
                                                  field_separator,
                                                  batch_size,
                                                  false)

        category_found              = args.container
        file_keyword_category_found = args.target_keyword_category
        target_field_found          = args.source_field

        built_in                    = nil
        file_ids                    = nil
        keywords                    = []
        files                       = []
        total_file_count            = 0
        total_files_updated         = 0  # For better readability
        offset                      = 0
        iterations                  = 0
        limit                       = batch_size.to_i.abs
        op                          = RestOptions.new

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
            msg = "Argument Error: Expected \"append\" or \"overwrite\" for fifth argument \"insert_mode\" in #{__callee__}. " +
                  "Instead got #{insert_mode.inspect}"
            logger.error(msg)
            abort
        end

        # Check the source_field field type
        built_in = (target_field_found.built_in == '1') ? true : false

        # Get keywords
        msg = "Retrieving keywords for keyword category => #{file_keyword_category_found.name.inspect}."
        logger.info(msg.green)

        op.add_option('limit','0')
        op.add_option('keyword_category_id',"#{file_keyword_category_found.id}")

        keywords = get_keywords(op)

        if keywords.empty?
            msg = "No keywords found in keyword category => #{file_keyword_category_found.name.inspect} " +
                  "with id #{file_keyword_category_found.id.inspect}"
            logger.error(msg)
            abort
        end

        op.clear
        
        # Get file ids
        msg = "Retrieving file ids in category => #{category_found.name.inspect}."
        logger.info(msg.green)

        op.add_option('limit','0')
        op.add_option('displayFields','id')
        op.add_option('category_id',"#{category_found.id}") # Returns files in specified project

        files = get_files(op)
        op.clear

        if files.empty?
            msg = "Category #{category_found.name.inspect} with id #{category_found.id.inspect} is empty."
            logger.error(msg)
            abort
        end

        # Extract file ids
        file_ids = files.map { |obj| obj.id.to_s }

        # Prep iterations loop
        total_file_count = file_ids.length

        msg = "Calculating batch size."
        logger.info(msg.green)

        iterations, remainder = total_file_count.divmod(batch_size)
        iterations += 1 unless remainder.zero?

        file_ids.each_slice(batch_size).with_index(1) do |subset,num|

            move_keywords_to_fields_and_update_oa(subset,num,iterations,op,total_files_updated)
            total_files_updated += subset.length

        end    
    end
end