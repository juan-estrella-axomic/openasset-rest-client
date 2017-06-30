# FieldLookupStrings class
# 
# @author Juan Estrella
class FieldLookupStrings

	# @!parse attr_accessor :id, :display_order, :value
	attr_accessor :id, :display_order, :value

	# Creates an FieldLookupStrings object
	#
	# @param data [Hash, nil] Takes a JSON object/Hash or no argument 
	# @return [FieldLookupStrings object]
	#
	# @example 
	#         fls_object = FieldLookupStrings.new
	def initialize(data=nil)
		json_obj = Validator::validate_argument(data,"FieldLookupStrings")     unless data.is_a?(String)
		json_obj = {"value" => data}                                           if data.is_a?(String)
		@id = json_obj['id']                      
		@display_order = json_obj['display_order']                  
		@value = json_obj['value']                	
	end

	# @!visibility private
	def json
		json_data = Hash.new
		json_data[:id] = @id                        unless @id.nil?
		json_data[:display_order] = @display_order  unless @display_order.nil?
		json_data[:value] = @value                  unless @value.nil?

		return json_data	
	end

end