require_relative 'Constants'

module FileMoveFieldDataToKeywordsByAlbum

    include Constants
    
	def __move_file_field_data_to_keywords_by_album(album=nil,
                                                 	target_keyword_category=nil,
                                                 	source_field=nil,
                                                 	field_separator=nil,
                                                 	batch_size=200)
        
        # Validate input:
        args = process_field_to_keyword_move_args('albums',
                                                   album,
                                                   target_keyword_category,
                                                   source_field,
                                                   field_separator,
                                                   batch_size)

        album_found                 = args.container
        file_keyword_category_found = args.target_keyword_category
        source_field_found          = args.source_field

        total_file_count            = nil
        built_in                    = nil
        file_ids                    = nil
        file_category_ids           = nil
        keyword_file_category_ids   = nil
        existing_keyword_categories = nil
        existing_keywords           = nil
        cat_id_string               = nil
        batch_size                  = batch_size.to_i.abs

        limit                       = batch_size # For better readability
        total_files_updated         = 0
        offset                      = 0
        iterations                  = 0
        files                       = []

        op                          = RestOptions.new

        # Get total file count
        total_file_count = album_found.files.length
        
        # Check the source_field field type
        built_in = (source_field_found.built_in == '1') ? true : false

        # Get all the categories associated with the files in the project then using the target_keyword_category,  
        # create the file keyword category in all the system categories that don't have them
        file_ids = album_found.files.map { |obj| obj.id }

        op.add_option('limit','0')
        op.add_option('id', file_ids.join(',')) #create query string from file id array
        op.add_option('displayFields','category_id')

        # Get categories found in album
        file_category_ids = get_files(op).uniq { |obj| obj.category_id }.map { |obj| obj.category_id.to_s }

        op.clear

        # Get the keyword categories associated with the files in the album
        cat_id_string = file_category_ids.join(',')
        op.add_option('limit', '0')
        op.add_option('category_id', cat_id_string)
        existing_keyword_categories = get_keyword_categories(op)
        
        op.clear

        # Check if any of the system categories found in the album DO NOT CONTAIN 
        # the target_keyword_category name and create it
        keyword_file_category_ids = existing_keyword_categories.reject do |obj| 
            obj.name.downcase != file_keyword_category_found.name 
        end.map do |obj| 
            obj.category_id.to_s 
        end.uniq

        # Make sure the keyword category is in all associated categories
        # Now loop throught the file categories, create the needed keyword categories for referencing below
        msg = "Creating keyword categories."
        logger.info(msg.green)

        file_category_ids.each do |file_cat_id|
            
            # Look for the category id in existing keyword categories to check 
            # if the file category already has a keyword category with that name
            unless keyword_file_category_ids.include?(file_cat_id.to_s)
                msg = "Actually creating keyword categories..."
                logger.info(msg.green)

                obj = KeywordCategories.new(file_keyword_category_found.name, file_cat_id)
                kwd_cat_obj = create_keyword_categories(obj, true).first
                
                unless kwd_cat_obj
                    msg = "Error creating keyword category in #{__callee__}"
                    logger.error(msg)
                    abort
                end
                
                existing_keyword_categories.push(kwd_cat_obj)
                
            else
                msg = "Keyword category in category #{file_cat_id} already exists"
                logger.warn(msg.yellow)
            end

        end


        # Get all file keywords for the keyword category name associated with all the file categories found in the album
        query_ids = existing_keyword_categories.map { |item| item.id }.join(',')
        
        op.add_option('keyword_category_id', query_ids)
        op.add_option('limit', '0')

        msg = "Getting existing keywords"
        logger.info(msg.green)

        existing_keywords = get_keywords(op)

        op.clear
        
        # Calculate number of requests needed based on specified batch_size
        msg = "Setting batch size."
        logger.info(msg.green)

        if total_file_count % batch_size == 0
            iterations = total_file_count / batch_size
        else
            iterations = total_file_count / batch_size + 1  #we'll need one more iteration to grab remaining
        end

        # Create update loop using iteration limit and batch size
        file_ids.each_slice(batch_size).with_index do |subset,num|

            num += 1
            
            # More efficient than setting the offset and limit in the query

            op.add_option('id', subset)
            op.add_option('keywords','all')
            op.add_option('fields','all')
            # Get current batch of files => body length used to track total files updated
            msg = "Batch #{num} of #{iterations} => Retrieving files."
            logger.info(msg.green)

            files = get_files(op)

            op.clear

            msg = "Batch #{num} of #{iterations} => Extracting keywords from \"#{source_field_found.name}\" field."
            logger.info(msg)

            keywords_to_create = []
            
            # Iterate through the files and find the keywords that need to be created
            files.each do |file|
                
                field_data      = nil
                field_obj_found = nil

                # Check if the field has any data in it
                if built_in
                    field_name = source_field_found.name.downcase.gsub(' ','_')
                    #puts "Field name 1 : #{field_name}"
                    field_data = file.instance_variable_get("@#{field_name}")
                    field_data = field_data.strip # In case a bunch of spaces are stored in the field
                    next if field_data.nil? || field_data == ''
                else
                    field_obj_found = file.fields.find { |f| f.id == source_field_found.id }
                    if field_obj_found.nil? || field_obj_found.values.first.nil? || field_obj_found.values.first.strip == ''
                        next
                    end
                    field_data = field_obj_found.values.first
                end

                # Split the string using the specified separator and remove empty strings
                keywords_to_append = field_data.split(field_separator).reject { |val| val.to_s.strip.empty? }

                # establish link between keyword and current file
                associated_kwd_cat = existing_keyword_categories.find do |obj| 
                    
                    obj.name.downcase == file_keyword_category_found.name.downcase && 
                    obj.category_id.to_s == file.category_id.to_s
     
                end           

                keywords_to_append.each do |val|
    
                    val = val.strip.gsub("\u00A9",'(c)').encode("iso-8859-1", invalid: :replace, undef: :replace)

                    # Check if the value exists in existing keywords
                    keyword_found_in_existing = existing_keywords.find do |k|
                        
                        # Match the existing keywords check by the name and the category
                        # id of the current file to establish the the link between the two

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

                        # Insert into keywords_to_create array
                        obj = Keywords.new(associated_kwd_cat.id, val)
                        keywords_to_create.push(obj)
                        
                    end
                end
            end        
            
            # Remove duplicate keywords in the same keyword category and create them
            unless keywords_to_create.empty?
                payload = keywords_to_create.uniq { |item| [item.name, item.keyword_category_id] }
                
                # Create the keywords for the current batch and set the generate objects flag to true.
                msg = "Batch #{num} of #{iterations} => creating keywords."
                logger.info(msg.green)

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
            msg = "Batch #{num} of #{iterations} => Tagging files with keywords."
            logger.info(msg.green)

            files.each do | file |
                #puts "In files tag before using instance_variable_get 2"
                field_data = nil
                file.original_filename = nil
                file.caption.to_s.gsub!(/\n+/,' ')

                # Look for the field and check if the field has any data in it
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
                    
                    # Split the string using the specified separator and remove empty strings
                    keywords = field_data.split(field_separator).reject { |val| val.to_s.strip.empty? }

                    # ESTABLISH LINK BETWEEN FILE AND KEYWORD
                    associated_kwd_cat = existing_keyword_categories.find do |item|
                        item.name.downcase == file_keyword_category_found.name.downcase &&
                        item.category_id.to_s == file.category_id.to_s
                    end

                    unless associated_kwd_cat
                        msg = "Associated keyword category retrieval failed in #{__callee__}"
                        logger.fatal(msg)
                        abort
                    end

                    # Loop through the keywords and tag the file
                    keywords.each do |value|
                        # Trim leading & trailing whitespace => OA also removes newlines and double spaces during creation
                        value = value.strip.gsub(/[\n\s]+/,' ').gsub("\u00A9",'(c)').encode("iso-8859-1", invalid: :replace, undef: :replace)
                        # Find the string in existing keywords
                        keyword_obj = existing_keywords.find do |item| 
                            begin           
                                item.name.downcase == value.downcase && associated_kwd_cat.id.to_s == item.keyword_category_id.to_s     
                            rescue
                                item.name == value && associated_kwd_cat.id.to_s == item.keyword_category_id.to_s
                            end
                        end

                        if keyword_obj
                            #check if current file is already tagged
                            already_tagged = file.keywords.find { |item| item.id.to_s == keyword_obj.id.to_s }
                            # Tag the file
                            unless already_tagged
                                msg = "Tagging #{file.filename.inspect} => #{keyword_obj.name}"
                                logger.info(msg.green)

                                file.keywords.push(NestedKeywordItems.new(keyword_obj.id))
                            end 
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