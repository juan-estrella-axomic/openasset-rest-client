module KeywordMover
	# @!visibility private
	def move_keywords_to_fields(objects,keywords,field,field_separator,mode)
        objects_to_update = []
        existing_field_lookup_strings = nil
        object_type = objects.first.class.to_s.chop # Projects => Project | Files => File

        # Allows dynamic access to nested keywords for both files and projects
        keyword_accessor = (objects.first.is_a?(Projects) ? '@project_' : '@') + 'keywords'

        # Allows access to project or file names attributes dynamically
        object_name = (objects.first.is_a?(Projects) ? '@name' : '@filename')

        # Check the source_field field type
        built_in = (field.built_in == '1') ? true : false

        # Retrieve existing field lookup strings if the field is a restricted field type
        if RESTRICTED_LIST_FIELD_TYPES.include?(field.field_display_type)
            op = RestOptions.new
            op.add_option('limit','0')
            existing_field_lookup_strings = get_field_lookup_strings(field,op)
        end
        
        objects.each do |object|

            next if object.instance_variable_get("#{keyword_accessor}").empty?
            
            if object.is_a?(Files)
                object.original_filename = nil
            end

            nested_kwd_ids = object.instance_variable_get("#{keyword_accessor}").map { |kwd| kwd.id.to_s }
    
            # Retrieve the actual keyword objects associated with the nested ids
            keyword_data = keywords.find_all { |k_obj| nested_kwd_ids.include?(k_obj.id.to_s) }
            keyword_data.sort_by! { |k| k.name.downcase }
    
            field_string = keyword_data.map(&:name).join(field_separator)

            next if field_string.empty?
            msg = ''
            if built_in

                field_name = field.name.downcase.gsub(' ','_')

                if mode == 'append'
                    data = file.instance_variable_get("#{field_name}").to_s.strip
                    data += field_separator + field_string
                elsif mode == 'overwrite'
                    data = field_string
                end

                object.instance_variable_set("@#{field_name}",data)
                msg = "Inserting #{data.inspect} into #{field.name.inspect} field" +
                      " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."   
                    
            else # Custom field
                # Check if there's already a value in the field
                index = object.fields.find_index { |f_obj| f_obj.id.to_s == field.id.to_s }        
        
                if index # There's data in the field
                    if mode == 'append'
                        if NORMAL_FIELD_TYPES.include?(field.field_display_type)

                            existing = object.fields[index].values.first
                            new_data = field_separator + field_string
                            object.fields[index].values = [existing + new_data]
                            msg = "Appending #{field_string.inspect} into #{field.name.inspect} field" +
                                  " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."
                                   
                        elsif RESTRICTED_LIST_FIELD_TYPES.include?(field.field_display_type)
        
                            existing_field_lookup_strings = create_missing_field_lookup_strings(keyword_data,existing_field_lookup_strings)
                            value = keyword_data.first.name
                            msg = "Inserting #{value.inspect} into #{field.name.inspect} field" +
                                  " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."
                            # Assign the value to the field
                            object.fields[index].values = [value]   unless keyword_data.empty?
                        
                        else      
                            msg = "#{object_type} keyword move operation not allowed to field display type " +
                                  "#{field.field_display_type.inspect}."
                            logger.error(msg)
                            abort
                        end
                    elsif  mode == 'overwrite'
                        if NORMAL_FIELD_TYPES.include?(field.field_display_type)
        
                            object.fields[index].values = [field_string]
                            msg = "Inserting #{field_string.inspect} into #{field.name.inspect} field" +
                                  " for #{object_type} => #{object.instance_variable_get("#{object_name}").to_s.inspect}."
                        
                        elsif RESTRICTED_LIST_FIELD_TYPES.include?(field.field_display_type)

                            existing_field_lookup_strings = create_missing_field_lookup_strings(keyword_data,existing_field_lookup_strings)
                            value = keyword_data.first.name
                            msg = "Inserting #{value.inspect} into #{field.name.inspect} field" +
                                  " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."
                            # Assign the value to the field
                            object.fields[index].values = [value]   unless keyword_data.empty?
                        
                        else
                            msg = "#{object_type} keyword move operation not allowed to field display type " +
                                  "#{field.field_display_type.inspect}."
                            logger.error(msg)
                            abort
                        end 
                    end
                else # No data in the field
                    if NORMAL_FIELD_TYPES.include?(field.field_display_type)
        
                        object.fields << NestedFieldItems.new(field.id.to_s, [field_string])
                        msg = "Inserting #{field_string.inspect} into #{field.name.inspect} field" +
                              " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."
        
                    elsif RESTRICTED_LIST_FIELD_TYPES.include?(field.field_display_type)
                        
                        existing_field_lookup_strings = create_missing_field_lookup_strings(keyword_data,existing_field_lookup_strings)
                        value = keyword_data.first.name
                        msg = "Inserting #{value.inspect} into #{field.name.inspect} field" +
                                " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."
                        # Insert the value to the field if there is one
                        object.fields << NestedFieldItems.new(field.id,[value]) unless keyword_data.empty?
                        
                    else
        
                        msg = "#{object_type} keyword move operation not allowed to field display type " +
                              "#{field.field_display_type.inspect}."
                        logger.error(msg)
                        abort

                    end
                end
        
            end
            logger.info(msg)
            objects_to_update << object
        end   
        objects_to_update
    end

    def create_missing_field_lookup_strings(keyword_data,existing)
        collection = existing
        keyword_data.each do |fk|
            fls_found = existing_field_lookup_strings.find { |fls| fls.value.downcase == fk.name.downcase }            
            # Create the field lookup string if not found and add to existing
            unless fls_found
                data = {:value => fk.name}
                fls_found = create_field_lookup_strings(field,data,true).first
                collection.push(fls_found)
            end     
        end
        collection
    end

    def move_keywords_to_fields_and_update_oa(subset,batch_number,iterations,query_options,updated_count)
        msg = "Batch #{num} of #{iterations} => Retrieving files."
        logger.info(msg)

        query_options.add_option('limit','0')
        query_options.add_option('keywords','all')
        query_options.add_option('fields','all')
        query_options.add_option('id',subset)

        # Get current batch of files
        files = get_files(query_options)
        query_options.clear

        # Move the file keywords to specified field
        processed_files = move_keywords_to_fields(files,keywords,target_field_found,field_separator,insert_mode)

        # Perform file update
        msg = "Batch #{num} of #{iterations} => Attempting to perform file updates."
        logger.info(msg.white)
        
        run_smart_update(processed_files,updated_count)
    end
end