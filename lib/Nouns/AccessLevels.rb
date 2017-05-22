class AccessLevels

	attr_accessor :id, :label

	def initialize(data=nil)
		json_obj = Validator.validate_argument(data,'AccessLevels')
		@id = json_obj['id']                    
		@label = json_obj['label']
	end                

	def json
		json_data = Hash.new
		json_data[:id] = @id                      unless @id.nil?
		json_data[:label] = @label                unless @label.nil?

		return json_data
	end
end