class Keywords

	attr_accessor :id, :keyword_category_id, :name

	def initialize(*args)
		json_obj = nil
		#This check is specific to the Fields object
		if args.length > 1 && args.first.is_a?(String)#Make sure only two non-null arguments are passed
			unless args.length == 2 && !args.include?(nil) && (args.first.is_a?(String) || args.first.is_a?(Integer)) &&
				(args[1].is_a?(String) || args[1].is_a?(Integer))
				warn "Argument Error:\n\tExpected either\n\t1. No Arguments\n\t2. A Hash\n\t" + 
					 "3. Two separate string arguments." +
					 " e.g. Keywords.new(keyword_category_id,name) in that order." + 
					 "\n\tInstead got #{args.inspect} => Creating empty Keywords object."
				json_obj = {}
			else
				#set grab the agruments and set up the json object
				json_obj = {"keyword_category_id" => args[0].to_s, "name" => args[1].to_s}
			end
		else
			json_obj = Validator::validate_argument(args.first,'Keywords')
		end

		@id = json_obj['id']
		@keyword_category_id = json_obj['keyword_category_id']
		@name = json_obj['name']
	end

	def json
		json_data = Hash.new
		json_data[:id] = @id   							  		 unless @id.nil?
		json_data[:keyword_category_id] = @keyword_category_id   unless @keyword_category_id.nil?
		json_data[:name] = @name                                 unless @name.nil?

		return json_data		
	end

end