module ArgumentHandler
	# @!visibility private
    def process_field_to_keyword_move_args(scope,
                                           container,
                                           target_keyword_category,
                                           source_field,
                                           field_separator,
                                           batch_size,
                                           allow_mutiple_results=false)

        op = RestOptions.new

        container_found             = nil
        keyword_category_found      = nil
        source_field_found          = nil

        if scope.downcase == 'albums'

            if container.is_a?(Albums) # Object
                op.add_option('id',container.id)
                container_found = get_albums(op).first

                unless container_found
                    msg = "Album id #{container.id} not found in OpenAsset. Aborting."
                    logger.error(msg)
                    abort
                end

            elsif (container.is_a?(String) && container.to_i > 0) || container.is_a?(Integer) # Album id
                op.add_option('id',container)
                container_found = get_albums(op).first

                unless container_found
                    msg = "Album id #{container.inspect} not found in OpenAsset. Aborting"
                    logger.error(msg)
                    abort
                end

            elsif container.is_a?(String) # Album name
                op.add_option('name',container)
                op.add_option('textMatching','exact')
                container_found = get_albums(op)

                if container_found.length > 1
                    msg = "Multiple #{scope} found named #{container.inspect}. Specify an id instead."
                    logger.error(msg)
                    abort
                end

                if container_found.empty?
                    msg = "Album named #{container.inspect} not found in OpenAsset. Aborting"
                    logger.error(msg)
                    abort
                end
                container_found = container_found.first
            else
                msg = "Argument Error: Expected a Albums object, Album name, or Album id for the first argument in #{__callee__}" +
                      "\n    Intead got #{container.inspect}"
                logger.error(msg)
                abort
            end

            unless container_found && !container_found.files.empty?
                msg = "Album #{container_found.name.inspect} is empty"
                logger.warn(msg.yellow)
            end

        elsif scope.downcase == 'projects'

            if container.is_a?(Projects) # Object
                op.add_option('id',container.id)
                container_found = get_projects(op).first

                unless container_found
                    msg = "Project id #{container.id} not found in OpenAsset. Aborting."
                    logger.error(msg)
                    abort
                end

            elsif (container.is_a?(String) && container.to_i > 0) || container.is_a?(Integer) # Album id
                op.add_option('id',container)
                container_found = get_projects(op).first

                unless container_found
                    msg = "Project id #{container} not found in OpenAsset. Aborting."
                    logger.error(msg)
                    abort
                end

            elsif container.is_a?(String) # project name
                op.add_option('name',container)
                op.add_option('textMatching','exact')
                container_found = get_projects(op)

                if container_found.length > 1
                    msg = "Multiple #{scope} found named #{container.inspect}. Specify an id instead."
                    logger.error(msg)
                    abort
                end

                if container_found.empty?
                    msg = "Project named #{container.inspect} not found in OpenAsset. Aborting."
                    logger.error(msg)
                    abort
                end

                container_found = container_found.first
            else
                msg = "Argument Error: Expected a Projects object, Project name, or Project id for the first argument in #{__callee__}" +
                      "\n    Intead got #{container.inspect}"
                logger.error(msg)
                abort
            end

        elsif scope.downcase == 'categories'

            if container.is_a?(Categories) # Object
                op.add_option('id',container.id)
                container_found = get_categories(op).first

                unless container_found
                    msg = "Category id #{container.id} not found in OpenAsset. Aborting."
                    logger.error(msg)
                    abort
                end

            elsif (container.is_a?(String) && container.to_i > 0) || container.is_a?(Integer) # Category id
                op.add_option('id',container)
                container_found = get_categories(op).first

                unless container_found
                    msg = "Category id #{container.inspect} not found in OpenAsset. Aborting."
                    logger.error(msg)
                    abort
                end

            elsif container.is_a?(String) # Category name

                op.add_option('name',container)
                op.add_option('textMatching','exact')
                container_found = get_categories(op)

                if container_found.length > 1
                    msg = "Multiple #{scope} found named #{container.inspect}. Specify an id instead."
                    logger.error(msg)
                    abort
                end

                if container_found.empty?
                    msg = "Category named #{container.inspect} not found in OpenAsset. Aborting."
                    logger.error(msg)
                    abort
                end

                container_found = container_found.first

            else
                msg = "Argument Error: Expected a Categories object, Category name, or Category id for the first argument in #{__callee__}" +
                "\n    Intead got #{container.inspect}"
                logger.error(msg)
                abort
            end

        end

        op.clear

        if target_keyword_category.is_a?(KeywordCategories) # Object

            op.add_option('id',target_keyword_category.id)
            keyword_category_found = get_keyword_categories(op).first

            unless keyword_category_found
                msg = "FILE Keyword Category id \"#{target_keyword_category.id}\" not found in OpenAsset. Aborting."
                logger.error(msg)
                abort
            end

        elsif (target_keyword_category.is_a?(String) &&
               target_keyword_category.to_i > 0) ||
               target_keyword_category.is_a?(Integer) # Keyword category id

            op.add_option('id',target_keyword_category)
            keyword_category_found = get_keyword_categories(op).first

            unless keyword_category_found
                msg = "FILE Keyword Category id \"#{target_keyword_category}\" not found in OpenAsset. Aborting."
                logger.error(msg)
                abort
            end

        elsif target_keyword_category.is_a?(String) # Keyword category name

            op.add_option('name',target_keyword_category)
            op.add_option('textMatching','exact')

            results = get_keyword_categories(op)

            if results.empty?
                msg = "FILE Keyword Category \"#{target_keyword_category}\" not found in OpenAsset. Aborting."
                logger.error(msg)
                abort
            end

            if results.length > 1 && allow_mutiple_results == false
                msg = "Multiple File keyword categories found with name => #{target_keyword_category.inspect}. Specify an id instead."
                logger.error(msg)
                abort
            elsif results.length > 1 && allow_mutiple_results == true
                keyword_category_found = results
            else
                keyword_category_found = results.first
            end

        else
            msg = "Argument Error: Expected \n    1.) File keyword categories object\n    2.) File keyword " +
                  "category name\n    3.) File keyword category id\nfor the second argument in #{__callee__}." +
                  "\n    Intead got #{target_keyword_category.inspect}"
            logger.error(msg)
            abort
        end

        op.clear

        if source_field.is_a?(Fields) # Object

            op.add_option('id',source_field.id)
            source_field_found = get_fields(op).first

            unless source_field_found
                msg = "Field id #{source_field.id} not found in OpenAsset. Aborting."
                logger.error(msg)
                abort
            end

        elsif (source_field.is_a?(String) && source_field.to_i > 0) || source_field.is_a?(Integer) # Field id

            op.add_option('id',source_field)
            source_field_found = get_fields(op).first

            unless source_field_found
                msg = "Field id #{source_field} not found in OpenAsset. Aborting."
                logger.error(msg)
                abort
            end

        elsif source_field.is_a?(String) # Field name

            op.add_option('name',source_field)
            op.add_option('textMatching','exact')
            results = get_fields(op)

            if results.length > 1
                msg = "Multiple Fields found named #{source_field.inspect}. Specify an id instead."
                logger.error(msg)
                abort
            end

            if results.empty?
                msg = "Field named #{source_field.inspect} not found in OpenAsset. Aborting."
                logger.error(msg)
                abort
            end

            source_field_found = results.first
        else
            msg = "Argument Error: Expected a Fields object, File Field name, or File Field id for the third argument in #{__callee__}" +
                  "\n    Intead got #{source_field.inspect}"
            logger.error(msg)
            abort
        end

        unless source_field_found.field_type == 'image'
            msg = "Field #{source_field_found.name.inspect} with id #{source_field_found.id.inspect} is not an image field. Aborting."
            logger.error(msg)
            abort
        end

        op.clear

        unless field_separator.is_a?(String) && !field_separator.nil?
            msg = "Argument Error: Expected a string value for the fourth argument \"field_separator\"." +
                  "\n    Instead got #{field_separator.inspect}."
            logger.error(msg)
            abort
        end

        unless batch_size.to_i > 0
            msg = "Argument Error: Expected a non zero numeric value for the fifth argument \"batch size\" in #{__callee__}." +
                  "\n    Instead got #{batch_size.inspect}."
            logger.error(msg)
            abort
        end

        args = Struct.new(:container, :source_field, :target_keyword_category)

        return args.new(container_found, source_field_found, keyword_category_found)

    end
end