# Groups class
# 
# @author Juan Estrella
class Groups

	# @!parse attr_accessor :alive, :id, :name
	attr_accessor :alive, :id, :name

	# Creates an Groups object
	#
	# @param data [Hash, nil] Takes a JSON object/Hash or no argument 
	# @return [Groups object]
	#
	# @example 
	#         group = Groups.new
	def initialize(data=nil)
		json_obj = Validator::validate_argument(data,'Groups')
		@alive = json_obj['alive']
		@id = json_obj['id']
		@name = json_obj['name']
	end

	# @!visibility private
	def json
		json_data = Hash.new
		json_data[:alive] = @alive    	unless @alive.nil?
		json_data[:id] = @id            unless @id.nil?
		json_data[:name] = @name        unless @name.nil?

		return json_data		
	end

end