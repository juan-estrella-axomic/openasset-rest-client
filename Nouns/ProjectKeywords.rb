class ProjectKeywords

	attr_accessor :id, :name, :project_count, :project_keyword_category_id

	def initialize(*args)
		
		if args.length > 1 #We only want one arguement or 2 non-null ones
			if args.length != 2 || args.include?(nil) || (!args[0].is_a?(String) && !args[0].is_a?(Integer)) || (!args[1].is_a?(String) && !args[1].is_a?(Integer))
				warn "Argument Error:\n\tExpected either\n\t1. No Arguments\n\t2. A Hash\n\t" + 
					 "3. Two separate string arguments." +
					 " e.g. ProjectKeywords.new(name,project_keyword_category_id) in that order." + 
					 "\n\tInstead got #{args.inspect} => Creating empty ProjectKeywords object."
			else
				#set grab the agruments and set up the json object
				json_obj = {"name" => args[0].to_s, "project_category_id" => args[1].to_s}
			end
		else
			json_obj = Validator::validate_argument(args.first,'ProjectKeywords')
		end

		@id = json_obj['id']
		@name = json_obj['name']
		@project_count = json_obj['project_count']
		@project_keyword_category_id = json_obj['project_keyword_category_id']
	end

	def json
		json_data = Hash.new
		json_data[:id] = @id   				                     			    unless @id.nil?
		json_data[:name] = @name                               				    unless @name.nil?
		json_data[:project_count] = @project_count               				unless @project_count.nil?
		json_data[:project_keyword_category_id] = @project_keyword_category_id  unless @project_keyword_category_id.nil?

		return json_data			
	end

end