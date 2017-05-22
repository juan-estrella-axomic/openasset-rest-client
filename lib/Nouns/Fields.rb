require_relative 'FieldLookupStrings.rb'

class Fields 

	attr_accessor :alive, :cardinality, :code, :description, :display_order, :field_display_type
	attr_accessor :field_type, :id, :include_on_info, :include_on_search, :name, :protected, :built_in

	def initialize(*args)
		json_obj = {}
		len = args.length
		#This check is specific to the Fields object
		if !args.empty? && args.first.is_a?(String)
			unless len == 3 && args[0].is_a?(String) && args[1].is_a?(String) && args[2].is_a?(String)
				warn "Argument Error:\n\tExpected either\n\t1. No Arguments\n\t2. A Hash\n\t" + 
					 "3. Three separate string arguments." +
					 " e.g. Fields.new(name,field_type,field_display_type) in that order." + 
					 "\n\tInstead got #{args.inspect} => Creating empty Fields object."
			end
			json_obj['name']               = args[0]
			json_obj['field_type']         = args[1]
			json_obj['field_display_type'] = args[2]
		else 
			json_obj = Validator::validate_argument(args.first,'Fields')
		end
		
		@alive = json_obj['alive']								
		@cardinality = json_obj['cardinality']					
		@code = json_obj['code']								
		@description = json_obj['description']					
		@display_order = json_obj['display_order']				
		@field_display_type = json_obj['field_display_type']     #enumerator
		@field_type = json_obj['field_type']					 #enumerator
		@id = json_obj['id'] 									
		@include_on_info = json_obj['include_on_info']          
		@include_on_search = json_obj['include_on_search']      
		@name = json_obj['name']								
		@protected = json_obj['protected']
		@built_in = json_obj['built_in']
		@field_lookup_strings = []

		if json_obj['fieldLookupStrings'].is_a?(Array) && !json_obj['fieldLookupStrings'].empty?
			@field_lookup_strings = json_obj['fieldLookupStrings'].map do |item|
				FieldLookupStrings.new(item)
			end					
		end						
	end

	def json
		json_data = Hash.new
		json_data[:alive] = @alive    							  unless @alive.nil?
		json_data[:cardinality] = @cardinality 					  unless @cardinality.nil?
		json_data[:code] = @code                    			  unless @code.nil?
		json_data[:description] = @description 					  unless @description.nil?
		json_data[:display_order] = @display_order 				  unless @display_order.nil?
		json_data[:field_display_type] = @field_display_type      unless @field_display_type.nil?
		json_data[:field_type] = @field_type                      unless @field_type.nil?
		json_data[:id] = @id                                      unless @id.nil?
		json_data[:include_on_info] = @include_on_info            unless @include_on_info.nil?
		json_data[:include_on_search] = @include_on_search        unless @include_on_search.nil?
		json_data[:name] = @name                                  unless @name.nil?
		json_data[:protected] = @protected                        unless @protected.nil?
		json_data[:built_in] = @built_in						  unless @built_in.nil?

		unless @field_lookup_strings.empty?
			json_data[:fieldLookupStrings] = @field_lookup_strings.map do |item|
				item.json
			end
		end

		return json_data
	end

end 
