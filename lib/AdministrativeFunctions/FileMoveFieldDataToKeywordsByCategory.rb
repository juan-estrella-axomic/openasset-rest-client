module FileMoveFieldDataToKeywordsByCategory

    def __move_file_field_data_to_keywords_by_category(category=nil,
                                                       target_keyword_category=nil,
                                                	   source_field=nil,
                                                       field_separator=nil,
                                                       batch_size=200)


    # Validate input:
    args = process_field_to_keyword_move_args('categories',
                                               category,
                                               target_keyword_category,
                                               source_field,
                                               field_separator,
                                               batch_size)
    
    category_found              = args.container
    file_keyword_category_found = args.target_keyword_category
    source_field_found          = args.source_field

    built_in                     = nil
    total_file_count            = nil
    existing_keywords           = nil
    batch_size                  = batch_size.to_i.abs
    iterations                  = 0
    offset                      = 0
    limit                       = batch_size # For better readability
    total_files_updated         = 0
    file_ids                    = nil
    op                          = RestOptions.new

    if file_keyword_category_found.category_id != category_found.id
        msg = "Specified keyword category #{file_keyword_category_found.name.inspect} " +
              "with id #{file_keyword_category_found.id.inspect} not found in #{category_found.name.inspect}."
        logger.error(msg)
        abort
    end

    # Get ids and total file count for the category
    op.add_option('category_id', category_found.id)
    op.add_option('displayFields', 'id')
    op.add_option('limit','0')
    file_ids = get_files(op).map { |obj| obj.id.to_s  }
    total_file_count = file_ids.length

    msg = "Total file count => #{total_file_count}"
    logger.info(msg.green)

    op.clear    

    # Check field type
    built_in = (source_field_found.built_in == '1') ? true : false

    # Get all file keywords in the specified keyword category
    op.add_option('keyword_category_id', file_keyword_category_found.id)
    op.add_option('limit', '0')
    existing_keywords = get_keywords(op)

    op.clear

    # Calculate number of requests needed based on specified batch_size
    if total_file_count % batch_size == 0
        iterations = total_file_count / batch_size
    else
        iterations = total_file_count / batch_size + 1  #we'll need one more iteration to grab remaining
    end

    # Create update loop using iteration limit and batch size
    file_ids.each_slice(batch_size).with_index do |subset,num|

        num += 1

        # More efficient than setting the offset and limit in the query
        
        op.add_option('id',subset)
        op.add_option('limit','0')
        op.add_option('keywords','all')
        op.add_option('fields','all')
        # Get current batch of files
        msg = "[INFO] Batch #{num} of #{iterations} => Retrieving files."
        logger.info(msg.green)

        files = get_files(op)
        
        op.clear

        keywords_to_create = []
        
        msg = "Batch #{num} of #{iterations} => Extracting keywords from #{source_field_found.name.inspect} field."
        logger.info(msg.green)

        # Iterate through the files and find the keywords that need to be created
        files.each do |file|
            
            field_data = nil
        
            # Look for the field and check if it has any data in it
            if built_in
                field_name = source_field_found.name.downcase.gsub(' ','_')
                field_data = file.instance_variable_get("@#{field_name}")
                field_data = field_data.strip
                next if field_data.nil? || field_data == ''
            else
                field_obj_found = file.fields.find { |f| f.id.to_s == source_field_found.id.to_s }
                if field_obj_found.nil? || field_obj_found.values.first.nil? || field_obj_found.values.first.strip == ''
                    next
                end
                field_data = field_obj_found.values.first
            end

            # Split the string using the specified separator and remove empty strings
            keywords_to_append = field_data.split(field_separator).reject { |val| val.to_s.strip.empty? }

            keywords_to_append.each do |val|

                # Remove leading and trailing white space
                val = val.strip.gsub("\u00A9",'(c)').encode("iso-8859-1", invalid: :replace, undef: :replace)

                # Check if the value exists in existing keywords
                keyword_found_in_existing = existing_keywords.find do |k|
                    begin 
                        k.name.downcase == val.downcase 
                    rescue
                        k.name == val
                    end
                end

                unless keyword_found_in_existing
                    # Populate list of keywords that need to be created
                    keywords_to_create.push(Keywords.new(file_keyword_category_found.id, val))
                end
                
            end

        end
        
        msg = "Batch #{num} of #{iterations} => Creating keywords."
        logger.info(msg.green)

        # Remove duplicate keywords => just in case
        unless keywords_to_create.empty?
            
            payload = keywords_to_create.uniq { |item| item.name }
            # Create the keywords for the current batch and set the generate objects flag to true.
            new_keywords = create_keywords(payload, true)

            # Append the returned keyword objects to the existing keywords array
            if new_keywords
                if new_keywords.is_a?(Array) && !new_keywords.empty?
                    # new keywords may contain error objects due to duplicates.
                    # Only add non error objects to the collection.
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

        msg = "Batch #{num} of #{iterations} => Tagging files."
        logger.info(msg.green)

        # Loop though the files again and tag them with the newly created keywords.
        files.each do | file |
            file.original_filename = nil
            file.caption.to_s.gsub!(/\n+/,' ') # Prevents 400 error when making update
            field_data = nil

            #9. Look for the field and check if the field has any data in it
            if built_in
                field_name = source_field_found.name.downcase.gsub(' ','_')
                field_data = file.instance_variable_get("@#{field_name}")
                field_data = field_data.strip
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

                # Loop through the keywords and tag the file
                keywords.each do |value|
                    # Trim leading & trailing whitespace and encode it to the same encoding used to create it
                    value = value.strip.gsub(/[\n\s]+/,' ').gsub("\u00A9",'(c)').encode("iso-8859-1", invalid: :replace, undef: :replace)
                    #find the string in existing keywords
                    keyword_obj = existing_keywords.find do |item| 
                        begin
                            item.name.downcase == value.downcase 
                        rescue
                            item.name == value 
                        end

                    end

                    if keyword_obj
                        #check if current file is already tagged
                        already_tagged = file.keywords.find { |item| item.id.to_s == keyword_obj.id.to_s }
                        # Tag the file
                        unless already_tagged
                            msg = "Tagging file #{file.filename.inspect} => #{keyword_obj.name.inspect}"
                            logger.info(msg.green)
                            file.keywords.push(NestedKeywordItems.new(keyword_obj.id))
                        end
                    else
                        msg = "Unable to retrieve previously created keyword #{value.inspect} in #{__callee__}"
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
end
end