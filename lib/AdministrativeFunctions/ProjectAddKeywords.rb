module ProjectAddKeywords

	def __project_add_keywords(projects=nil,proj_keywords=nil)
        
        #1.validate class types
        #Looking for Project objects or an array of Project objects
        unless projects.is_a?(Projects) || (projects.is_a?(Array) && 
                projects.first.is_a?(Projects))
            warn "Argument Error: Invalid type for first argument in \"project_add_keywords\" method.\n" +
                 "    Expected one the following:\n" +
                 "    1. Single Projects object\n" +
                 "    2. Array of Projects objects\n" +
                 "    Instead got => #{projects.inspect}"
            return false            
        end 

        unless proj_keywords.is_a?(ProjectKeywords) || (proj_keywords.is_a?(Array) && 
                proj_keywords.first.is_a?(ProjectKeywords))
            warn "Argument Error: Invalid type for second argument in \"project_add_keywords\" method.\n" +
                 "    Expected one the following:\n" +
                 "    1. Single ProjectKeywords object\n" +
                 "    2. Array of ProjectKeywords objects\n" +
                 "    Instead got => #{proj_keywords.inspect}"
            return false            
        end 
        #2.build project json array for request body
        #There are four acceptable combinations for the arguments.
        #project_keyword = Struct.new(:id)

        if projects.is_a?(Projects)  
            if proj_keywords.is_a?(ProjectKeywords) #1. Two Single objects
                uri = URI.parse(@uri + "/Projects/#{projects.id}/ProjectKeywords/#{proj_keywords.id}")
                post(uri,{},false)
            else                        #2. One Project object and an array of project Keyword objects
                #loop through Projects objects and append the new nested keyword to them
                proj_keywords.each do |keyword|
                    #projects.project_keywords << project_keyword.new(keyword.id)
                    projects.project_keywords << NestedProjectKeywordItems.new(proj_keywords.id)  
                end
                projects.project_keywords.uniq! { |npk| npk.id }
                uri = URI.parse(@uri + "/Projects")
                put(uri,projects,false)
            end
        else         
            if proj_keywords.is_a?(Array)    #3. Two arrays
                projects.each do |proj|
                    proj_keywords.each do |keyword|
                        #proj.project_keywords << project_keyword.new(keyword.id)
                        proj.project_keywords << NestedProjectKeywordItems.new(proj_keywords.id)
                    end
                    proj.project_keywords.uniq! { |npk| npk.id }
                end

                uri = URI.parse(@uri + "/Projects")
                put(uri,projects,false)
            else                        #4. Projects array and a single Keywords object
                projects.each do |proj|
                    #proj.project_keywords << project_keyword.new(proj_keywords.id)
                    proj.project_keywords << NestedProjectKeywordItems.new(proj_keywords.id)
                end
                proj.project_keywords.uniq! { |npk| npk.id }    
                uri = URI.parse(@uri + "/Projects") #/ProjectKeywords/:id/Projects 
                put(uri,projects,false)                    #shortcut not implemented yet                    
            end
        end
    end
end