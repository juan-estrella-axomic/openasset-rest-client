module KeywordMover
	# @!visibility private
	def move_keywords_to_fields(objects,keywords,field,field_separator,mode)
            
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
            keyword_data = keywords.find_all do |k_obj| 

                nested_kwd_ids.include?(k_obj.id.to_s) 
            
            end.sort do | k1, k2 | 
                
                k1.name.downcase <=> k2.name.downcase
            
            end
    
            field_string = keyword_data.map(&:name).join(field_separator)

            next if field_string.empty?
            
            if built_in

                if mode == 'append'
                    
                    field_name = field.name.downcase.gsub(' ','_')
                    #puts "Field name: #{field_name}"
                    data = file.instance_variable_get("#{field_name}")

                    if data.nil? || data.to_s.strip == ''
                        data = field_string
                    else
                        data = data.to_s.strip + field_separator + field_string
                    end

                    object.instance_variable_set("@#{field_name}",data)

                    msg = "Appending #{data.inspect} into #{field.name.inspect} field" +
                          " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."

                    logger.info(msg.green)

                elsif mode == 'overwrite'

                    field_name = field.name.downcase.gsub(' ','_')
                    #puts "Field name: #{field_name}"
                    data = field_string

                    object.instance_variable_set("@#{field_name}",data)

                    msg = "Inserting #{data.inspect} into #{field.name.inspect} field" +
                          " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."
                    
                    logger.info(msg.green)

                end
                    
            else # Custom field

                # Check if there's already a value in the field
                index = object.fields.find_index { |f_obj| f_obj.id.to_s == field.id.to_s }        
        
                if index # There's data in the field
                    
                    if mode == 'append'
        
                        if NORMAL_FIELD_TYPES.include?(field.field_display_type)
        
                            object.fields[index].values = 
                                [object.fields[index].values.first + field_separator + field_string]
        
                            msg = "Appending #{field_string.inspect} into #{field.name.inspect} field" +
                                  " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."

                            logger.info(msg.green)
                        
                        elsif RESTRICTED_LIST_FIELD_TYPES.include?(field.field_display_type)
        
                            keyword_data.each do |fk|

                                fls_found = existing_field_lookup_strings.find { |fls| fls.value.downcase == fk.name.downcase }
                                
                                # Create the field lookup string if not found and add to existing
                                unless fls_found
                                    data = {:value => fk.name}
                                    fls_found = create_field_lookup_strings(field,data,true).first
                                    existing_field_lookup_strings.push(fls_found)
                                end
        
                                #file_add_field_data(file,field,fk.name.to_s) # Easy but SLOW
        
                                msg = "Inserting #{fk.name.inspect} into #{field.name.inspect} field" +
                                      " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."

                                logger.info(msg.green)
        
                            end

                            # Assign the value to the field
                            object.fields[index].values = [keyword_data.first.name]        unless keyword_data.empty?
                        
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

                            logger.info(msg.green)
                        
                        elsif RESTRICTED_LIST_FIELD_TYPES.include?(field.field_display_type)
        
                            keyword_data.each do |fk|

                                fls_found = existing_field_lookup_strings.find { |fls| fls.value.downcase == fk.name.downcase }
                                
                                # Create the field lookup string if not found and add to existing
                                unless fls_found
                                    data = {:value => fk.name}
                                    fls_found = create_field_lookup_strings(field,data,true).first
                                    existing_field_lookup_strings.push(fls_found)
                                end

                                # Assign the value to the field
                                # object.fields[index].values = [fls_found.value]
                                
                                #file_add_field_data(file,field,fk.name.to_s) # Easy but SLOW
        
                                msg = "Inserting #{fk.name.inspect} into #{field.name.inspect} field" +
                                      " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."

                                logger.info(msg.green)
        
                            end
                    
                            object.fields[index].values = [keyword_data.first.name]     unless keyword_data.empty?
                        
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

                        logger.info(msg.green)
        
                    elsif RESTRICTED_LIST_FIELD_TYPES.include?(field.field_display_type)
                        
                        keyword_data.each do |fk|                

                            fls_found = existing_field_lookup_strings.find { |fls| fls.value.downcase == fk.name.downcase }

                            # Create the field lookup string if not found and add to existing
                            unless fls_found
                                data = {:value => fk.name}
                                fls_found = create_field_lookup_strings(field,data,true).first
                                existing_field_lookup_strings.push(fls_found)
                            end
                            
                            #file_add_field_data(file,field,fk.name.to_s) # SLOWWWW
        
                            msg = "Inserting #{fk.name.inspect} into #{field.name.inspect} field" +
                                  " for #{object_type} => #{object.instance_variable_get("#{object_name}").inspect}."

                            logger.info(msg.green)
        
                        end
                        
                        # Insert the value to the field if there is one
                        object.fields << NestedFieldItems.new(field.id,[keyword_data.first.name]) unless keyword_data.empty?
                        
                    else
        
                        msg = "#{object_type} keyword move operation not allowed to field display type " +
                              "#{field.field_display_type.inspect}."
                        logger.error(msg)
                        abort
        
                    end
        
                end
        
            end

        end
    
        return objects
    end
end