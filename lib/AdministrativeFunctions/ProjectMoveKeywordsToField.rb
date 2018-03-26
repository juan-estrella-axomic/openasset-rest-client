module ProjectMoveKeywordsToField

	def __move_project_keywords_to_field(source_project_keyword_category=nil,
                                         target_project_field=nil,
                                         field_separator=nil,
                                         insert_mode=nil,
                                         batch_size=200)

        project_ids                    = nil
        projects                       = nil
        project_field_found            = nil
        project_keyword_category_found = nil
        project_keywords               = nil
        total_project_count            = 0
        iterations                     = 0
        offset                         = 0
        total_projects_updated         = 0
        batch_size                     = batch_size.to_i.abs
        limit                          = batch_size
        op                             = RestOptions.new

        # Validate input:
        
        # Retrieve project keyword category
        if source_project_keyword_category.is_a?(ProjectKeywordCategories) &&  # Object
            !source_project_keyword_category.id.nil?

            op.add_option('id',source_project_keyword_category.id)
            project_keyword_category_found = get_project_keyword_categories(op).first

        elsif (source_project_keyword_category.is_a?(String) && source_project_keyword_category.to_i > 0) ||  # Id
                (source_project_keyword_category.is_a?(Integer) && !source_project_keyword_category.zero?)

            op.add_option('id',source_project_keyword_category)
            project_keyword_category_found = get_project_keyword_categories(op).first

        elsif source_project_keyword_category.is_a?(String) # Name

            op.add_option('name',source_project_keyword_category)
            op.add_option('textMatching','exact')
            project_keyword_category_found = get_project_keyword_categories(op)

            unless project_keyword_category_found
                msg = "Project keyword category with name #{target_project_keyword_category.inspect} not found in OpenAsset."
                logger.error(msg)
                abort
            end

            if project_keyword_category_found.length > 1
                msg = "Multiple Project keyword categories found with search query #{op.get_options.inspect}." +
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
        if target_project_field.is_a?(Fields) && !target_project_field.id.nil?# Object

            op.add_option('id',target_project_field.id)
            project_field_found = get_fields(op).first

            unless project_field_found
                msg = "Field with id #{project_field.id.inspect} not found in OpenAsset."
                logger.error(msg)
                abort
            end

        elsif (target_project_field.is_a?(String) && !target_project_field.to_i.zero?) ||  # Id
              (target_project_field.is_a?(Integer) && !target_project_field.zero?)

            op.add_option('id',target_project_field)
            project_field_found = get_fields(op).first

            unless project_field_found
                msg = "Field with id #{target_project_field.inspect} not found in OpenAsset."
                logger.error(msg)
                abort
            end

        elsif target_project_field.is_a?(String) # Field Name

            op.add_option('name',target_project_field)
            op.add_option('textMatching','exact')
            project_field_found = get_fields(op)

            if project_field_found.empty?
                msg = "Field with name #{target_project_field.inspect} not found in OpenAsset."
                logger.error(msg)
                abort
            end

            if project_field_found.length > 1
                msg = "Multiple fields found with name #{target_project_field.inspect}. Specify an id instead."
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
                  "\nInstead got #{target_project_field.inspect}."
            logger.error(msg)
            abort
        end

        # Make sure it's a project field
        unless project_field_found.field_type == 'project'
            msg = "Error: Specified field #{project_field_found.name.inspect} with id " +
                  "#{project_field_found.id.inspect} is not a project field."
            logger.error(msg)
            abort
        end
        
        if RESTRICTED_LIST_FIELD_TYPES.include?(project_field_found.field_display_type)
            answer = nil
            error  = "\nInvalid input. Please enter \"yes\" or \"no\".\n> "
            message = "Warning: You are inserting keywords into a restricted field type. " +
                      "\n     Project keywords are sorted in alphabetical order. " +
                      "\n     All project keywords will be created as options but only the first one will be displayed in the field." +
                      "\nContinue? (Yes/no)\n> "

            print message.yellow

            while answer != 'yes' && answer != 'no'

                print error unless answer.nil?

                answer = gets.chomp.to_s.downcase

                abort("You entered #{answer.inspect}. Exiting.\n\n") if answer.downcase == 'no' || answer == 'n'

                break if answer == 'yes' || answer == 'y'

            end          
        
        end

        if field_separator.nil?
            msg = "You must specify a field separator."
            logger.error(msg)
            abort
        end

        unless ['append','overwrite'].include?(insert_mode.to_s)
            msg = "Error: Expected \"append\" or \"overwrite\" for fourth argument \"insert_mode\" in #{__callee__}. " +
                  "Instead got #{insert_mode.inspect}"
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
        op.add_option('limit','0')
        op.add_option('project_keyword_category_id',project_keyword_category_found.id)

        project_keywords = get_project_keywords(op)

        op.clear

        # Get projects
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
        if total_project_count % batch_size == 0
            iterations = total_project_count / batch_size
        else
            iterations = total_project_count / batch_size + 1 # To grab remaining
        end

        project_ids.each_slice(batch_size).with_index do |subset,num|

            num += 1

            start_index = offset
            end_index   = offset + limit
            ids         = project_ids[start_index...end_index].join(',')

            op.add_option('limit','0')
            op.add_option('keywords','all')
            op.add_option('fields','all')
            op.add_option('id',ids)

            msg = "Batch #{num} of #{iterations} => Retrieving projects."
            logger.info(msg.green)

            projects = get_projects(op)

            op.clear

            # Move project keywords to field
            msg = "Batch #{num} of #{iterations} => Extacting project keywords."
            logger.info(msg.green)

            processed_projects = move_keywords_to_fields(projects,
                                                         project_keywords,
                                                         project_field_found,
                                                         field_separator,
                                                         insert_mode)

            # Update projects
            msg = "Batch #{num} of #{iterations} => Attempting to perform project updates."
            logger.info(msg.green)

            run_smart_update(processed_projects,total_projects_updated)

            total_projects_updated += subset.length

        end            

    end

end