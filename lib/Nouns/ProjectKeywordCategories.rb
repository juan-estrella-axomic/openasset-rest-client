class ProjectKeywordCategories

	attr_accessor :code, :display_order, :id, :name

	def initialize(*args)
		json_obj = nil	
		len = args.length
		
		if (args[0].is_a?(String) || args[0].is_a?(Integer)) && len == 1
			json_obj = {"name" => args[0].to_s}
		elsif (!args[0].is_a?(String) || !args[0].is_a?(Integer)) && len == 1
			json_obj = Validator::validate_argument(args.first,'ProjectKeywordCategories')
		else #This executes if you pass more than one argument
			warn "Argument Error:\n\tExpected either\n\t1. No Arguments\n\t2. A Hash\n\t" + 
						"3. One string argument." +
						" e.g. ProjectKeywordCategories.new(name)." + 
						"\n\tInstead got #{args.inspect} => Creating empty ProjectKeywordCategories object."
			json_obj = {}
		end
		
		@code = json_obj['code']
		@display_order = json_obj['display_order']
		@id = json_obj['id']
		@name = json_obj['name']
	end

	def json
		json_data = Hash.new
		json_data[:code] = @id   				        unless @code.nil?
		json_data[:display_order] = @display_order      unless @display_order.nil?
		json_data[:id] = @id                            unless @id.nil?
		json_data[:name] = @name                        unless @name.nil?

		return json_data	
	end

end