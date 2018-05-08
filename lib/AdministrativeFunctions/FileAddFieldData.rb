require_relative 'Constants'

module FileAddFieldData

    include Constants
    
	def __file_add_field_data(file=nil,field=nil,value=nil)
        
            #validate class types
            unless file.is_a?(Files) || (file.is_a?(String) && (file.to_i != 0)) || file.is_a?(Integer)
                warn "Argument Error: Invalid type for first argument in \"file_add_field_data\" method.\n" +
                     "    Expected Single Files object, Numeric string, or Integer for file id\n" +
                     "    Instead got => #{file.inspect}"
                return            
            end 

            unless field.is_a?(Fields) ||  (field.is_a?(String) && (field.to_i != 0)) || field.is_a?(Integer)
                warn "Argument Error: Invalid type for second argument in \"file_add_field_data\" method.\n" +
                     "    Expected Single Fields object, Numeric string, or Integer for field id\n" +
                     "    Instead got => #{field.inspect}"
                return             
            end

            unless value.is_a?(String) || value.is_a?(Integer) || value.is_a?(Float)
                warn "Argument Error: Invalid type for third argument in \"file_add_field_data\" method.\n" +
                     "    Expected a String, Integer, or Float\n" +
                     "    Instead got => #{value.inspect}"
                return            
            end

            res           = nil
            current_file  = nil
            current_field = nil
            current_value = value.to_s.strip

            file_class  = file.class.to_s
            field_class = field.class.to_s

            #set up objects
            if file_class == 'Files'
                current_file = file
            elsif file_class == 'String' || file_class == 'Integer' 
                #retrieve Projects object matching id provided
                uri = URI.parse(@uri + "/Files")
                option = RestOptions.new
                option.add_option("id",file.to_s)
                current_file = get(uri,option).first
                unless current_file
                    warn "ERROR: Could not find File with matching id of \"#{file.to_s}\"...Exiting"
                    return
                end
            else
                warn "Unknown Error retrieving Files. Exiting."
                return
            end

            if field_class == 'Fields'
                current_field = field
            elsif field_class == 'String' || field_class == 'Integer'
                uri = URI.parse(@uri + "/Fields")
                option = RestOptions.new
                option.add_option("id",field.to_s)
                current_field = get(uri,option).first
                unless current_field
                    warn "ERROR: Could not find Field with matching id of \"#{field.to_s}\"\n" +
                         "=> Hint: It either doesn't exist or it's disabled."
                    return false
                end
                unless current_field.field_type == "image"
                    warn "ERROR: Expected a File field. The field provided is a \"#{current_field.field_type}\" field."
                    return false
                end        
            else
                warn "Unknown Error retrieving Field. Exiting."
                return
            end

            #Prep endpoint to be used for update
            files_endpoint = URI.parse(@uri + "/Files/#{current_file.id}/Fields")

            #Check the field type -> if its option or fixed suggestion we must make the option
            #available first before we can apply it to the Files resource
            if RESTRICTED_LIST_FIELD_TYPES.include?(current_field.field_display_type)
                
                lookup_string_endpoint = URI.parse(@uri + "/Fields/#{current_field.id}/FieldLookupStrings")
           
                #Grab all the available FieldLookupStrings for the specified Fields resource
                #field_lookup_strings = get(lookup_string_endpoint,nil)
                op = RestOptions.new
                op.add_option('limit',0)
                field_lookup_strings = get_field_lookup_strings(current_field,op)
                #check if the value in the third argument is currently an available option for the field
                lookup_string_exists = field_lookup_strings.find { |item| current_value.downcase == item.value.downcase }
          
                # add the option to the restricted field first if it's not there, otherwise you get a 400 bad 
                # request error saying that it couldn't find the string value for the restricted field specified 
                # when making a PUT request on the FILES resource you are currently working on
                unless lookup_string_exists
                    data = {:value => current_value }
                    response = post(lookup_string_endpoint,data,false)
                    unless response.kind_of?(Net::HTTPSuccess)
                        puts "FAILED TO CREATE FIELD LOOKUP STRING => #{current_value}"
                        return
                    end
                end

                # Now that we know the option is available, we can update the File we are currently working with
                index = current_file.fields.find_index { |nstd_field| nstd_field.id.to_s == current_field.id.to_s }

                if index
                    current_file.fields[index].values = [current_value]
                else
                    current_file.fields << NestedFieldItems.new(current_field.id,[current_value])
                end

                res = update_files(current_file,false)

            elsif IMAGE_BUILT_IN_FIELD_CODES.include?(current_field.code.downcase) ||
                  IMAGE_BUILT_IN_FIELD_NAMES.include?(current_field.name.downcase)     # This handles copyright holder and photographer fields
           
                  rest_code = current_field.rest_code

                  op = RestOptions.new
                  op.add_option('limit',1)
                  op.add_option('name',current_value)
                  op.add_option('textMatching','exact')

                  if rest_code == 'copyright_holder_id'
                    # Create Copyright holder if needed
                    copyright_holder = get_copyright_holders(op).first 
                    unless copyright_holder
                        obj = CopyrightHolders.new(current_value)
                        copyright_holder = create_copyright_holders(obj,true).first
                        unless copyright_holder
                            logger.error("Could not create copyright holder #{current_value} in OpenAsset")
                            return
                        end
                    end
                    current_file.copyright_holder_id = copyright_holder.id
                    
                  elsif rest_code == 'photographer_id'
                    # Create Photographer if needed
                    photographer = get_photographers(op).first 
                    unless photographer
                        obj = Photographers.new(current_value)
                        photographer = create_photographers(obj,true).first
                        unless photographer
                            logger.error("Could not create photographer #{current_value} in OpenAsset")
                            return
                        end
                    end
                    current_file.photographer_id = photographer.id
                  
                  end
                  # Update file
                  res = update_files(current_file)

            elsif current_field.field_display_type == "date"
                #make sure we get the right date format
                #Accepts mm-dd-yyyy, mm-dd-yy, mm/dd/yyyy, mm/dd/yy
                date_regex = Regexp::new('((\d{2}-\d{2}-(\d{4}|\d{2}))|(\d{2}\/\d{2}\/(\d{4}|\d{2})))')
                unless (value =~ date_regex) == 0
                    warn "ERROR: Invalid date format. Expected one of the following => \"mm-dd-yyyy\" | \"mm-dd-yy\" | \"mm/dd/yyyy\" | \"mm/dd/yy\""
                    return
                end

                value.gsub!('/','-')
                date_arr = value.split('-') #convert date string to array for easy manipulation

                if date_arr.last.length == 2  #convert mm-dd-yy to mm-dd-yyyy format
                    four_digit_year = '20' + date_arr.last
                    date_arr[-1] = four_digit_year
                end
                #convert date to 14 digit unix time stamp
                value = date_arr[-1] + date_arr[-3] + date_arr[-2] + '000000'

                #Apply the date to our current Files resource
                data = {:id => current_field.id, :values => [value.to_s]}
                res = put(files_endpoint,data,false)


            elsif NORMAL_FIELD_TYPES.include?(current_field.field_display_type)
                #some fields are built into Files so they can't be inserted into
                #the Files nested fields resource. We get around this by using the
                #name of the field object to access the corresponding built-in field attribute
                #inside the Files object.
                if current_field.built_in.to_s == "1"  #For built in fields
                    files_endpoint =  URI.parse(@uri + '/Files') #change endpoint bc field is built_in
                    field_name = current_field.name.downcase.gsub(' ','_') #convert the current field's name
                                                                           #into the associated files' built_in attribute name
                    
                    #access built-in field
                    unless current_file.instance_variable_defined?('@'+field_name)
                        warn "ERROR: The specified attirbute \"#{field_name}\" does not" + 
                             " exist in the File. Exiting."
                        exit
                    end
                    
                    current_file.instance_variable_set('@'+field_name, value)
                    res = put(files_endpoint,current_file,false)
                else    #For regular non-built in fields

                    data = {:id => current_field.id, :values => [value.to_s]}
                    endpoint = URI.parse(@uri + "/Files" + "/#{current_file.id}" + "/Fields")
                    res = put(endpoint,data,false)
                    
                end

            elsif current_field.field_display_type == 'boolean'

                #validate value
                unless ALLOWED_BOOLEAN_FIELD_OPTIONS.include?(value.to_s.strip)
                    msg = "Invalid value #{value.inspect} for \"On/Off Switch\" field type.\n" +
                          "Acceptable Values => #{ALLOWED_BOOLEAN_FIELD_OPTIONS.inspect}"
                    logger.error(msg)
                    return
                end
                
                
                #Interpret input
                #Even indicies in the field options array are On and Odd indicies are Off
                bool_val = ""
                if ALLOWED_BOOLEAN_FIELD_OPTIONS.find_index(value.to_s.strip).even?
                    bool_val = "1"
                elsif ALLOWED_BOOLEAN_FIELD_OPTIONS.find_index(value.to_s.strip).odd?
                    bool_val = "0"
                end

                #Prep the endpoint
                files_endpoint =  URI.parse(@uri + '/Files')

                current_file.fields.each do |obj| 
                    if obj.id == current_field.id
                        obj.values[0] = bool_val
                    end  
                end
                
                #Actually do the update
                res = put(files_endpoint,current_file,false)
            else
                msg = "The field specified does not have a valid field_display_type." +
                      "Value provided => #{field.field_display_type.inspect}"
                logger.error(msg)
                return
            end

            if @verbose
                msg = "Setting value: \"#{current_value}\" to \"#{current_field.name}\" field " +
                      "for file => #{current_file.filename}"
                logger.info(msg.green)
            end
            return res
        end
end