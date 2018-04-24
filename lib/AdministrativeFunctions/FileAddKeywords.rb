module FileAddKeywords
	
	def __file_add_keywords(files=nil,keywords=nil)
        
        #1.validate class types
        #Looking for File objects or an array of File objects
        unless files.is_a?(Files) || (files.is_a?(Array) && files.first.is_a?(Files))
            warn "Argument Error: Invalid type for first argument in \"file_add_keywords\" method.\n" +
                 "    Expected one the following:\n" +
                 "    1. Single Files object\n" +
                 "    2. Array of Files objects\n" +
                 "    Instead got => #{files.inspect}"
            return false            
        end 

        unless keywords.is_a?(Keywords) || (keywords.is_a?(Array) && keywords.first.is_a?(Keywords))
            warn "Argument Error: Invalid type for second argument in \"file_add_keywords\" method.\n" +
                 "    Expected one the following:\n" +
                 "    1. Single Keywords object\n" +
                 "    2. Array of Keywords objects\n" +
                 "    Instead got => #{keywords.inspect}"
            return false            
        end 
        
        #2.build file json array for request body
        #There are four acceptable combinations for the arguments.
     
        if files.is_a?(Files)  
            if keywords.is_a?(Keywords) #1. Two Single objects
                uri = URI.parse(@uri + "/Files/#{files.id}/Keywords/#{keywords.id}")
                post(uri,{})
            else                        #2. One File object and an array of Keywords objects
                #loop through keywords objects and append the new nested keyword to the file

                simple_file_obj = Files.new
                simple_file_obj.id = files.id
                simple_file_obj.keywords = files.keywords  # retain existing keyword associations

                keywords.each do |keyword|
                    simple_file_obj.keywords << NestedKeywordItems.new(keyword.id)
                end
                
                simple_file_obj.keywords.uniq! { |nki| nki.id } # Remove duplicate keyword entries

                uri = URI.parse(@uri + "/Files")
                put(uri,simple_file_obj,false)
            end
        else        
            if keywords.is_a?(Array)    #3. Two arrays
                keywords.uniq! { |k_obj| k_obj.id }
                keywords.each do |keyword|
                    uri = URI.parse(@uri + "/Keywords/#{keyword.id}/Files")
                    data = files.map { |files_obj| {:id => files_obj.id} }
                    data.uniq! { |h| h[:id] } # Remove duplicate File entries
                    post(uri,data)
                end
            else                        #4. Files array and a single Keywords object
                uri = URI.parse(@uri + "/Keywords/#{keywords.id}/Files")
                data = files.map { |files_obj| {:id => files_obj.id} }
                data.uniq! { |h| h[:id] } # Remove duplicate File entries
                post(uri,data)
            end
        end
        
    end
end