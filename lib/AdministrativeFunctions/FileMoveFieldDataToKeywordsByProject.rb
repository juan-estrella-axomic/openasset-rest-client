require_relative 'Constants'

module FileMoveFieldDataToKeywordsByProject

    include Constants

	def __move_file_field_data_to_keywords_by_project(project=nil,
                                                     target_keyword_category=nil,
                                                     source_field=nil,
                                                     field_separator=nil,
                                                     batch_size=200)
        # Validate input:
        args = process_field_to_keyword_move_args('projects',
                                                   project,
                                                   target_keyword_category,
                                                   source_field,
                                                   field_separator,
                                                   batch_size)

        project_found               = args.container
        file_keyword_category_found = args.target_keyword_category
        source_field_found          = args.source_field

        built_in                     = nil
        file_category_ids           = nil
        file_ids                    = nil
        results                     = nil
        existing_keywords           = nil
        existing_keyword_categories = nil
        total_file_count            = 0
        total_files_updated         = 0  # For better readability
        offset                      = 0
        iterations                  = 0
        limit                       = batch_size.to_i.abs
        op                          = RestOptions.new

        cat_id_string               = ''
        query_ids                   = ''
        keyword_file_category_ids   = ''

        # Check the source_field field type
        built_in = (source_field_found.built_in == '1') ? true : false

        # Get all the categories associated with the files in the project then using the target_keyword_category,
        # create the file keyword category in all the system categories that don't have them

        # Capture associated system categories
        op.add_option('limit','0')
        op.add_option('project_id',project_found.id)
        op.add_option('displayFields','id,category_id')

        msg = "Retrieving files and file categories associated with project."
        logger.info(msg.green)

        # Get category ids and file ids
        results           = get_files(op)
        file_category_ids = results.map { |obj| obj.category_id  }.uniq
        file_ids          = results.map { |obj| obj.id }
        total_file_count  = file_ids.length

        op.clear

        msg = "Total file count => #{total_file_count}"
        logger.info(msg.green)

        # Get the keyword categories associated with the files in the project
        cat_id_string = file_category_ids.join(',')
        op.add_option('limit', '0')
        op.add_option('category_id', cat_id_string)

        existing_keyword_categories = get_keyword_categories(op)

        op.clear

        # Check if any of the file categories found in the project DO NOT CONTAIN
        # the target_keyword_category name and create it
        keyword_file_category_ids = existing_keyword_categories.map { |obj| obj.category_id.to_s }.uniq

        #puts keyword_file_category_ids

        msg = "Detecting needed keyword categories."
        logger.info(msg.green)

        file_category_ids.each do |file_cat_id|

            # Look for the category id in existing keyword categories to check
            # if the file category already has the keyword category we need (target keyword category)
            unless keyword_file_category_ids.include?(file_cat_id.to_s)
                obj = KeywordCategories.new(file_keyword_category_found.name, file_cat_id)
                kwd_cat_obj = create_keyword_categories(obj, true).first

                unless kwd_cat_obj
                    msg = "Keyword category creation failed in #{__callee__} method."
                    logger.error(msg)
                    abort
                end

                existing_keyword_categories.push(kwd_cat_obj)
            else
                msg = "Keyword category in category #{file_cat_id} already exists."
                logger.warn(msg.yellow)
            end

        end

        # Get all file keywords associated with all the file categories found in the project
        query_ids = existing_keyword_categories.map { |item| item.id }.join(',')

        op.add_option('keyword_category_id', query_ids)
        op.add_option('limit', '0')

        msg = "Retrieving existing keywords"
        logger.info(msg.green)

        existing_keywords = get_keywords(op)

        op.clear

        # Get the file count and calculate number of requests needed based on specified batch_size
        msg = "Calulating batch size."
        logger.info(msg.green)

        if total_file_count % batch_size == 0
            iterations = total_file_count / batch_size
        else
            iterations = total_file_count / batch_size + 1  #we'll need one more iteration to grab remaining
        end

        # Set up loop controls
        # Create update loop using iteration limit and batch size
        file_ids.each_slice(batch_size).with_index do |subset,num|

            num += 1
            # More efficient than setting the offset and limit in the query
            # TO DO: Implement this in the other admin functions

            op.add_option('id', subset)
            op.add_option('limit','0')
            op.add_option('keywords','all')
            op.add_option('fields','all')
            # Get current batch of files => body length of response used to track total files updated
            msg = "Batch #{num} of #{iterations} => Retrieving files."
            logger.info(msg.green)

            files = get_files(op)

            op.clear

            #puts "File objects #{files.inspect}"
            keywords_to_create = []

            msg = "Batch #{num} of #{iterations} => Extracting Keywords from fields."
            logger.info(msg.green)

            # Iterate through the files and find the keywords that need to be created
            files.each do |file|
                #puts "In files create keywords from field before using instance_variable_get 1"
                field_data      = nil
                field_obj_found = nil

                # Check if the field has any data in it
                if built_in
                    field_name = source_field_found.name.downcase.gsub(' ','_')
                    #puts "Field name 1 : #{field_name}"
                    field_data = file.instance_variable_get("@#{field_name}")
                    field_data = field_data.strip
                    next if field_data.nil? || field_data == ''
                else
                    field_obj_found = file.fields.find { |f| f.id == source_field_found.id }
                    if field_obj_found.nil? || field_obj_found.values.first.nil? || field_obj_found.values.first.strip == ''
                        next
                    end
                    field_data = field_obj_found.values.first
                end

                # Establish link between keyword and current file
                associated_kwd_cat = existing_keyword_categories.find do |obj|
                    obj.name.downcase == file_keyword_category_found.name.downcase &&
                    obj.category_id.to_s == file.category_id.to_s
                end

                unless associated_kwd_cat
                    msg = "Unable to retrieve associated keyword category!"
                    logger.fatal(msg)
                    abort
                end

                # split the string using the specified separator and remove empty strings
                keywords_to_append = field_data.split(field_separator).reject { |val| val.to_s.strip.empty? }

                keywords_to_append.each do |val|
                    val = val.gsub(/[\n\s]+/,' ').gsub("\u00A9",'(c)').encode("iso-8859-1", invalid: :replace, undef: :replace)
                    # Check if the value exists in existing keywords
                    keyword_found_in_existing = existing_keywords.find do |k|

                        begin
                            # In case we get an invalid input string like "\xA9" => copyright binary representation
                            # The downcase method can choke on this depending on the platform
                            # It works in windows but chokes in linux and possibly mac OS
                            k.name.downcase == val.downcase && k.keyword_category_id == associated_kwd_cat.id
                        rescue
                            k.name == val && k.keyword_category_id == associated_kwd_cat.id
                        end

                    end

                    if !keyword_found_in_existing
                        # find keyword cat id matching the category id of current file to establish the association
                        #puts "KEYWORD CATEGORIES "
                        #pp existing_keyword_categories
                        obj = existing_keyword_categories.find do |item|
                            item.category_id.to_s == file.category_id.to_s &&
                            item.name.downcase == file_keyword_category_found.name.downcase
                        end
                        #puts "Existing keyword categories object"
                        #pp obj
                        # Insert into keywords_to_create array
                        keywords_to_create.push(Keywords.new(obj.id, val))

                    end

                end
            end

            # Remove duplicate keywords in the same keyword category and create them
            unless keywords_to_create.empty?
                payload = keywords_to_create.uniq { |item| [item.name, item.keyword_category_id] }

                # Create the keywords for the current batch and set the generate objects flag to true.
                puts "[INFO] Batch #{num} of #{iterations} => Creating Keywords."
                new_keywords = create_keywords(payload, true)

                # Append the returned keyword objects to the existing keywords array
                if new_keywords
                    if new_keywords.is_a?(Array) && !new_keywords.empty?
                        new_keywords.each do |item|
                            existing_keywords.push(item) unless item.is_a?(Error)
                        end
                    else
                        msg = "An error occured creating keywords in #{__callee__}"
                        logger.error(msg)
                        abort
                    end
                end
            end

            # Loop though the files again and tag them with the newly created keywords.
            # This is faster than making individual requests
            msg = "Batch #{num} of #{iterations} => Tagging files."
            logger.info(msg.green)

            files.each do | file |
                #puts "In files tag before using instance_variable_get 2"
                field_data      = nil
                field_obj_found = nil
                file.caption.to_s.gsub!(/\n+/,' ') # Prevents 400 error caused by newlines in caption field
                file.original_filename = nil # Prevents 400 error when the filename extension and
                                             # original filename extension don't match.
                # Look for the field and check if the field has any data in it
                if built_in
                    field_name = source_field_found.name.downcase.gsub(' ','_')
                    #puts "Field name: #{field_name}"
                    field_data = file.instance_variable_get("@#{field_name}")
                    field_data = field_data.strip
                    #puts "Field value: #{field_data}"
                    next if field_data.nil? || field_data == ''
                else
                    field_obj_found = file.fields.find { |f| f.id.to_s == source_field_found.id.to_s }
                    if field_obj_found.nil? || field_obj_found.values.first.nil? || field_obj_found.values.first.strip == ''
                        next
                    end
                    field_data = field_obj_found.values.first
                end

                if field_data

                    # Remove empty strings
                    keywords = field_data.split(field_separator).reject { |val| val.to_s.strip.empty? }


                    # ESTABLISH LINK BETWEEN FILE AND KEYWORD
                    associated_kwd_cat = existing_keyword_categories.find do |item|
                        item.name.downcase == file_keyword_category_found.name.downcase &&
                        item.category_id.to_s == file.category_id.to_s
                    end

                    unless associated_kwd_cat
                        msg = "Existing keyword category retrieval failure in #{__callee__}"
                        logger.fatal(msg)
                        abort
                    end

                    # Loop through the keywords and tag the file
                    keywords.each do |value|
                        # Trim leading/trailing/mutltiple whitespaces and remove newlines
                        value = value.strip.gsub(/[\n\s]+/,' ').gsub("\u00A9",'(c)').encode("iso-8859-1", invalid: :replace, undef: :replace)

                        # Find the string in existing keywords
                        keyword_obj = existing_keywords.find do |item|
                            begin
                                item.name.downcase == value.downcase && associated_kwd_cat.id.to_s == item.keyword_category_id.to_s
                            rescue
                                item.name == value &&
                                associated_kwd_cat.id.to_s == item.keyword_category_id.to_s
                            end

                        end

                        if keyword_obj
                            # check if current file is already tagged
                            already_tagged = file.keywords.find { |item| item.to_s == keyword_obj.id.to_s }
                            # Tag the file
                            file.keywords.push(NestedKeywordItems.new(keyword_obj.id)) unless already_tagged
                        else
                            msg = "Unable to retrieve previously created keyword! => #{value.inspect} in #{__callee__}"
                            logger.fatal(msg)
                            abort
                        end

                    end

                end
            end

            msg = "Batch #{num} of #{iterations} => Attempting to perform file updates."
            logger.info(msg.white)

            # Update files
            run_smart_update(files,total_files_updated)

            total_files_updated += subset.length

        end
        logger.info('Done.')
    end
end