class CopyrightHolders

	attr_accessor :copyright_policy_id, :id, :name

	def initialize(data=nil)
		json_obj = Validator::validate_argument(data,'CopyrightHolders') unless data.is_a?(String)
		json_obj = {"name" => data}                                      if data.is_a?(String)
		@copyright_policy_id = json_obj['copyright_policy_id']     
		@id = json_obj['id']                                       
		@name = json_obj['name']								   	
	end

	def json
		json_data = Hash.new
		json_data[:copyright_policy_id] = @copyright_policy_id    unless @copyright_policy_id.nil?
		json_data[:id] = @id                    				  unless @id.nil?
		json_data[:name] = @name                                  unless @name.nil?

		return json_data	
	end

end