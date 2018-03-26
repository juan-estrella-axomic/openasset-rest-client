module ProjectMoveFieldDataToKeywords

	def __move_project_field_data_to_keywords(target_project_keyword_category=nil,
                                              project_field=nil,
                                              field_separator=nil,
                                              batch_size=200)

        project_ids                    = nil
        project_field_found            = nil
        built_in                       = nil
        project_keyword_category_found = nil
        projects                       = []
        existing_project_keywords      = []
        total_project_count            = 0
        iterations                     = 0
        offset                         = 0
        total_projects_updated         = 0
        batch_size                     = batch_size.to_i.abs
        limit                          = batch_size
        op                             = RestOptions.new

        # Validate input:
        
        # Retrieve project keyword category
        if target_project_keyword_category.is_a?(ProjectKeywordCategories) &&  # Object
        !target_project_keyword_category.id.nil?

	        op.add_option('id',target_project_keyword_category.id)
	        project_keyword_category_found = get_project_keyword_categories(op).first

        elsif (target_project_keyword_category.is_a?(String) && target_project_keyword_category.to_i > 0) ||  # Id
              (target_project_keyword_category.is_a?(Integer) && !target_project_keyword_category.zero?)

            op.add_option('id',target_project_keyword_category)
            project_keyword_category_found = get_project_keyword_categories(op).first

        elsif target_project_keyword_category.is_a?(String) # Name

            op.add_option('name',target_project_keyword_category)
            op.add_option('textMatching','exact')
            project_keyword_category_found = get_project_keyword_categories(op)

            unless project_keyword_category_found
                msg = "Project keyword category with name #{target_project_keyword_category.inspect} not found in OpenAsset."
                logger.error(msg)
                abort
            end

            if project_keyword_category_found.length > 1
                msg = "Error: Multiple Project keyword categories found with search query #{op.get_options.inspect}." +
                      " Specify an id instead."
                logger.error(msg)
                abort
            else
                project_keyword_category_found = project_keyword_category_found.first
            end

        else
            msg = "Argument Error: Expected one of the following: " +
                  "\n    1. Valid project keyword category object." +
                  "\n    2. Project keyword category id." +
                  "\n    3. Project keyword category name." +
                  "\nfor first argument in #{__callee__} method." +
                  "\nInstead got #{target_project_keyword_category.inspect}."
            logger.error(msg)
            abort
        end

        # Make sure it's a project keyword catgory
        unless project_keyword_category_found.is_a?(ProjectKeywordCategories)
            msg = "Error: Specified Project keyword category named #{project_keyword_category_found.name.inspect} with id " +
                  "#{project_keyword_category_found.id.inspect} is actually a #{project_keyword_category_found.class.inspect}."
            logger.error(msg)
            abort
        end

        op.clear

        # Retrieve project field
        if project_field.is_a?(Fields) && !project_field.id.nil?# Object

            op.add_option('id',project_field.id)
            project_field_found = get_fields(op).first

            unless project_field_found
                msg = "Field with id #{project_field.id.inspect} not found in OpenAsset."
                logger.error(msg)
                abort
            end

        elsif (project_field.is_a?(String) && !project_field.to_i.zero?) ||  # Id
            (project_field.is_a?(Integer) && !project_field.zero?)

            op.add_option('id',project_field)
            project_field_found = get_fields(op).first

            unless project_field_found
                msg = "Field with id #{project_field.inspect} not found in OpenAsset."
                logger.error(msg)
                abort
            end

        elsif project_field.is_a?(String) # Name

            op.add_option('name',project_field)
            op.add_option('textMatching','exact')
            project_field_found = get_fields(op)

            if project_field_found.empty?
                msg = "Field with name #{project_field.inspect} not found in OpenAsset."
                logger.error(msg)
                abort
            end

            if project_field_found.length > 1
                msg = "Error: Multiple fields found with name #{project_field.inspect}. Specify an id instead."
                logger.error(msg)
                abort
            else
                project_field_found = project_field_found.first
            end
        else 
            msg = "Error: Expected one of the following: " +
                  "\n    1. Valid Fields object." +
                  "\n    2. Field id." +
                  "\n    3. Field name." +
                  "\nfor second argument in #{__callee__} method." +
                  "\nInstead got #{project_field.inspect}."
            logger.error(msg)
            abort
        end

        # Make sure it's a project field
        unless project_field_found.field_type == 'project'
            msg = "Error: Specified field #{project_field_found.name.inspect} with id " +
                  "#{project_field_found.id.inspect} is not a project field"
            logger.error(msg)
            abort
        end

        built_in = (project_field_found.built_in == '1') ? true : false 

        if field_separator.nil?
            msg = "You Must specify field separator."
            logger.error(msg)
            abort
        end

        if batch_size.zero?
            msg = "Invalid batch size. Specify a positive numeric value or use default value of 200."
            logger.error(msg)
            abort
        end

        op.clear

        # Get projects keywords
        msg = "Retrieving project keywords."
        logger.info(msg.green)

        op.add_option('limit','0')
        op.add_option('project_keyword_category_id',project_keyword_category_found.id)

        existing_project_keywords = get_project_keywords(op)
        
        op.clear

        op.add_option('limit','0')
        op.add_option('displayFields','id')

        project_ids = get_projects(op).map { |obj| obj.id.to_s }

        if project_ids.length.zero?
            msg = "No Projects found in OpenAsset!"
            logger.error(msg)
            abort
        end

        op.clear

        total_project_count = project_ids.length

        # Set up iterations loop
        msg = "Calculating batch size"
        logger.info(msg.green)

        if total_project_count % batch_size == 0
            iterations = total_project_count / batch_size
        else
            iterations = total_project_count / batch_size + 1 # To grab remaining
        end

        project_ids.each_slice(batch_size).with_index do |subset,num|

            num += 1

            op.add_option('limit','0')
            op.add_option('id',subset)
            op.add_option('projectKeywords','all')
            op.add_option('fields','all')

            msg = "Batch #{num} of #{iterations} => Retrieving projects."
            logger.info(msg.green)

            projects = get_projects(op)

            op.clear

            if projects.empty?
                msg = "Project retrieval failure in #{__callee__} method."
                logger.fatal(msg)
                abort
            end

            keywords_to_create = []
            
            msg = "Batch #{num} of #{iterations} => Extracting Keywords from field."
            logger.info(msg.green)

            # Iterate through the projects and find the project keywords that need to be created
            projects.each do |project|
                #puts "In files create keywords from field before using instance_variable_get 1"
                field_data      = nil
                field_obj_found = nil

                # Check if the field has any data in it
                if built_in
                    field_name = project_field_found.name.downcase.gsub(' ','_')
                    #puts "Field name 1 : #{field_name}"
                    field_data = project.instance_variable_get("@#{field_name}")
                    field_data = field_data.strip
                    next if field_data.nil? || field_data == ''
                else
                    field_obj_found = project.fields.find { |f| f.id == project_field_found.id }
                   
                    if field_obj_found.nil? || field_obj_found.values.first.nil? || field_obj_found.values.first.strip == ''
                        next
                    end
                   
                    field_data = field_obj_found.values.first
                    
                end

                # split the string using the specified separator and remove empty strings
                project_keywords_to_append = field_data.split(field_separator).reject { |val| val.to_s.strip.empty? }

                project_keywords_to_append.each do |val|
                    
                    val = val.strip.gsub(/[\n\s]+/,' ').gsub("\u00A9",'(c)').encode("iso-8859-1", invalid: :replace, undef: :replace)
                    # Check if the value exists in existing keywords
                    keyword = existing_project_keywords.find do |k|

                        begin
                            # In case we get an invalid input string like "\xA9" => copyright binary representation
                            # The downcase method can choke on this depending on the platform
                            # It works in windows but chokes in linux and possibly mac OS
                            k.name.downcase == val.downcase 
                        rescue
                            k.name == val 
                        end

                    end

                    unless keyword
                        # Insert into keywords_to_create array
                        keywords_to_create.push(ProjectKeywords.new(val,project_keyword_category_found.id))
                    end
                    
                end
            end

            # Remove entries with the same name then create new keywords
            unless keywords_to_create.empty?

                payload = keywords_to_create.uniq { |item| item.name }
                
                # Create the project keywords for the current batch and set the generate objects flag to true.
                msg = "Batch #{num} of #{iterations} => Creating Project Keywords."
                logger.info(msg.green)

                new_keywords = create_project_keywords(payload, true)

                # Append the returned project keyword objects to the existing keywords array
                if new_keywords    
                    new_keywords.each do |item| 
                        existing_project_keywords.push(item) unless item.is_a?(Error)
                    end
                end
            
            end
            
            # Loop though the projects again and tag them with the newly created project keywords.
            # This is faster than making individual requests
            msg = "Batch #{num} of #{iterations} => Tagging Projects."
            logger.info(msg.green)

            projects.each do |project|
                
                field_data      = nil
                field_obj_found = nil

                # Look for the field and check if the field has any data in it
                if built_in
                    field_name = project_field_found.name.downcase.gsub(' ','_')
                    #puts "Field name: #{field_name}"
                    field_data = project.instance_variable_get("@#{field_name}")
                    field_data = field_data.strip
                    #puts "Field value: #{field_data}"
                    next if field_data.nil? || field_data == ''
                else
                    field_obj_found = project.fields.find { |f| f.id.to_s == project_field_found.id.to_s }
                    if field_obj_found.nil? || field_obj_found.values.first.nil? || field_obj_found.values.first.strip == ''
                        next
                    end
                    field_data = field_obj_found.values.first
                end

                # Remove empty strings
                keywords = field_data.split(field_separator).reject { |val| val.to_s.strip.empty? }

                # Loop through the keywords and tag the file
                keywords.each do |value|
                    # Trim leading & trailing whitespace
                    value = value.strip.gsub(/[\n\s]+/,' ').gsub("\u00A9",'(c)').encode("iso-8859-1", invalid: :replace, undef: :replace)
                    # Find the string in existing keywords
                    proj_keyword_obj = existing_project_keywords.find do |item| 
                        begin
                            item.name.downcase == value.downcase
                        rescue
                            item.name == value
                        end

                    end

                    if proj_keyword_obj
                        # check if current file is already tagged
                        already_tagged = project.project_keywords.find { |item| item.id.to_s == proj_keyword_obj.id.to_s }
                        # Tag the project
                        msg = "Tagging project #{project.code.inspect} with => #{value.inspect}."
                        logger.info(msg.green)

                        project.project_keywords.push(NestedProjectKeywordItems.new(proj_keyword_obj.id)) unless already_tagged
                    else
                        msg = "Unable to retrieve previously created keyword! => #{value.inspect} in #{__callee__}"
                        logger.fatal(msg)
                        abort
                    end
                    
                end
                    
            end

            # Update projects
            msg = "Batch #{num} of #{iterations} => Attempting to perform project updates."
            logger.info(msg.green)

            run_smart_update(projects,total_projects_updated)

            total_projects_updated += subset.length

        end            

    end

end