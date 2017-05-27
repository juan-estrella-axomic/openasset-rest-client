class Groups

	attr_accessor :alive, :id, :name

	def initialize(data=nil)
		json_obj = Validator::validate_argument(data,'Groups')
		@alive = json_obj['alive']
		@id = json_obj['id']
		@name = json_obj['name']
	end

	def json
		json_data = Hash.new
		json_data[:alive] = @alive    	unless @alive.nil?
		json_data[:id] = @id            unless @id.nil?
		json_data[:name] = @name        unless @name.nil?

		return json_data		
	end

end