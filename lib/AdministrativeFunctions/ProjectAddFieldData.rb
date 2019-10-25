require_relative 'Constants'

module ProjectAddFieldData

    include Constants

	def __project_add_field_data(project=nil,field=nil,value=nil)

        #validate class types
        unless project.is_a?(Projects) || (project.is_a?(String) && (project.to_i != 0)) || project.is_a?(Integer)
            warn "Argument Error: Invalid type for first argument in \"project_add_field_data\" method.\n" +
                 "    Expected Single Projects object, a Numeric string or Integer for a Project id\n" +
                 "    Instead got => #{project.inspect}"
            return
        end

        unless field.is_a?(Fields) ||  (field.is_a?(String) && (field.to_i != 0)) || field.is_a?(Integer)
            warn "Argument Error: Invalid type for second argument in \"project_add_field_data\" method.\n" +
                 "    Expected Single Projects object, Numeric string, or Integer for Projects id.\n" +
                 "    Instead got => #{field.inspect}"
            return
        end

        unless value.is_a?(String) || value.is_a?(Integer)
            warn "Argument Error: Invalid type for third argument in \"project_add_field_data\" method.\n" +
                 "    Expected a String or an Integer.\n" +
                 "    Instead got => #{value.inspect}"
            return
        end

        #NOTE: Date fields use the mm-dd-yyyy format
        current_project = nil
        current_field   = nil
        current_value    = value.to_s.strip

        project_class  = project.class.to_s
        field_class    = field.class.to_s
        res            = nil
        #set up objects
        if project_class == 'Projects'
            current_project = project
        elsif project_class == 'String' || project_class == 'Integer'
            #retrieve Projects object matching id provided
            uri = URI.parse(@uri + "/Projects")
            option = RestOptions.new
            option.add_option("id",project.to_s)
            current_project = get(uri,option).first
            unless current_project
                warn "ERROR: Could not find Project with matching id of \"#{project.to_s}\"...Exiting"
                return
            end
        else
            warn "Unknown Error retrieving project. Exiting."
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
                return
            end
            unless current_field.field_type == "project"
                warn "ERROR: Expected a Project field. The field provided is a \"#{current_field.field_type}\" field."
                return
            end
        else
            warn "Unknown Error retrieving field. Exiting."
            return
        end

        #Prep endpoint shortcut to be used for update
        projects_endpoint = URI.parse(@uri + "/Projects/#{current_project.id}/Fields")

        #Check the field type -> if its option or fixed suggestion we must make the option
        #available first before we can apply it to the Files resource
        if RESTRICTED_LIST_FIELD_TYPES.include?(current_field.field_display_type)

            lookup_string_endpoint = URI.parse(@uri + "/Fields/#{current_field.id}/FieldLookupStrings")

            #Grab all the available FieldLookupStrings for the specified Fields resource
            field_lookup_strings = get(lookup_string_endpoint,nil)

            #check if the value in the third argument is currently an available option for the field
            lookup_string_exists = field_lookup_strings.find {
                |item| item.value.strip.downcase == value.strip.downcase
            }

            # add the option to the restricted field first if it's not there,
            #   otherwise you get a 400 bad request error saying that it couldn't
            #   find the string value for the restricted field specified when
            #   making a PUT request on the PROJECTS resource you are currently
            #   working on
            if lookup_string_exists
                # this is so we have the proper capitalization for the value
                value = lookup_string_exists.value
            else
                data = {:value => value}
                response = post(lookup_string_endpoint,data,false)
                return unless response.kind_of? Net::HTTPSuccess
            end

            #Now that we know the option is available, we can update the Project
            index = current_project.fields.find_index { |nested_field| nested_field.id.to_s == current_field.id.to_s }

            if index
                current_project.fields[index].values = [value]
            else
                current_project.fields << NestedFieldItems.new(current_field.id,[value])
            end

            res = update_projects(current_project,false)

            #data = {:id => current_field.id, :values => [value.to_s]}
            #put(projects_endpoint,data,false)

            if @verbose
                msg = "Adding value: \"#{value}\" to \"#{current_field.name}\" field" +
                      "for project => #{current_project.code} - #{current_project.name}"
                logger.info(msg.green)
            end

        elsif current_field.field_display_type == "date"
            #make sure we get the right date format
            #Accepts mm-dd-yyyy, mm-dd-yy, mm/dd/yyyy, mm/dd/yy
            date_regex = Regexp::new('^((\d{2}-\d{2}-(\d{4}|\d{2}))|(\d{2}\/\d{2}\/(\d{4}|\d{2})))$')
            ymd_date = Regexp::new('^((\d{4}-\d{2}-\d{2})|(\d{4}\/\d{2}\/\d{2}))$')
            raw_date =Regexp::new('^\d{14}$')
            unless date_regex.match(value)|| ymd_date.match(value) || raw_date.match(value)
                warn 'ERROR: Invalid date format. Expected one of the following => "mm-dd-yyyy" | ' \
                        '"mm-dd-yy" | "mm/dd/yyyy" | "mm/dd/yy" | "yyyy-mm-dd" | "yyyy/mm/dd" | ' \
                        'YYYYMMDDxxxxxx'
                return
            end

            value.gsub!('/','-')
            date_arr = value.split('-') #convert date string to array for easy manipulation
            suffix = '000000'

            if ymd_date.match(value)
                value = value.gsub('-','') + suffix
            elsif date_regex.match(value)
                if date_arr.last.length == 2  #convert mm-dd-yy to mm-dd-yyyy format
                    four_digit_year = '20' + date_arr.last
                    date_arr[-1] = four_digit_year
                end
                #convert date to 14 digit unix time stamp
                value = date_arr[-1] + date_arr[-3] + date_arr[-2] + suffix
            end

            value = '19700101000100' if value.eql?('19700101000000') # REST API doesn't accept base epoch time

            #Apply the date to our current Files resource
            data = {:id => current_field.id, :values => [value.to_s]}
            res = put(projects_endpoint,data,false) #Make the update

        elsif NORMAL_FIELD_TYPES.include?(current_field.field_display_type) #For regular fields
            #some fields are built into Projects so they can't be inserted into
            #the Projects nested fields resource. We get around this by using the
            #name of the field object to access the corresponding built-in field attribute
            #inside the Projects object.

            if current_field.built_in.to_s == "1"  #For built in fields
                projects_endpoint =  URI.parse(@uri + '/Projects') #change endpoint bc field is built_in
                field_name = current_field.name.downcase.gsub(' ','_')

                unless current_project.instance_variable_defined?('@'+field_name)
                    warn "ERROR: The specified attribute \"#{field_name}\" does not" +
                         " exist in the Project. Exiting."
                    Thread.exit
                    #exit(-1)
                end
                #update the project
                current_project.instance_variable_set('@'+field_name, value)
                #Make the update request
                res = put(projects_endpoint,current_project,false)

            else                                                        #For regular non-built in fields
                data = {:id => current_field.id, :values => [value.to_s]}
                res = put(projects_endpoint,data,false)
            end

        elsif current_field.field_display_type == 'boolean'
            value = value.to_s.downcase.strip
            #validate value
            unless ALLOWED_BOOLEAN_FIELD_OPTIONS.include?(value.to_s.strip)
                msg = "Error: Invalid value #{value.inspect} for \"On/Off Switch\" field type.\n" +
                      "Acceptable Values => #{ALLOWED_BOOLEAN_FIELD_OPTIONS.inspect}"
                logger.error(msg)
                return
            end

            #Interpret input
            #Even indicies in the field options array are On and Odd indicies are Off
            bool_val = ""
            if ALLOWED_BOOLEAN_FIELD_OPTIONS.find_index(value).even?
                bool_val = "1"
            elsif ALLOWED_BOOLEAN_FIELD_OPTIONS.find_index(value).odd?
                bool_val = "0"
            end

            #Update the object
            projects_endpoint =  URI.parse(@uri + '/Projects')

            #Check if field is populated
            index = current_project.fields.find_index { |obj| obj.id == current_field.id }

            if index
                current_project.fields[index].values = [bool_val]
            else
                current_project.fields << NestedFieldItems.new(current_field.id,[bool_val])
            end

            #Update current value variable for @verbose statement below
            current_value = bool_val

            #Acutally perform the update request
            res = put(projects_endpoint,current_project,false)

        else
            warn "Error: The field specified does not have a valid field_display_type." +
                 "Value provided => #{field.field_display_type.inspect}"
        end

        if @verbose
            msg = "Setting value: \"#{current_value}\" to \"#{current_field.name}\" field " +
                  "for project => #{current_project.code} - #{current_project.name}"
            logger.info(msg.green)
        end
        return res
    end
end