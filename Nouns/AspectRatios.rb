class AspectRatios

	attr_accessor :id, :code, :label

	def initialize(data=nil)
		json_obj = Validator::validate_argument(data,'AspectRatios')
		@id = json_obj['id']                      
		@code = json_obj['code']                  
		@label = json_obj['label']                	
	end

	def json
		json_data = Hash.new
		json_data[:id] = @id                      unless @id.nil?
		json_data[:code] = @code                  unless @code.nil?
		json_data[:label] = @label                unless @label.nil?

		return json_data	
	end

end