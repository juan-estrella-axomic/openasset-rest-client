class RestOptions

	def initialize
		@options = ''
	end

	private
	#Designed to handle single values and arrays of values ("john, joe , , jim,") => "john,joe,jim"
	def clean(value)
		str = nil
		if value.is_a?(String) || value.is_a?(Integer)
			str_array = value.split(',') #spilt it
			str_array = str_array.uniq	 #remove duplicates	
			str_array = str_array.reject {|value| value.strip.length == 0} #remove empty values
			str       = str_array.map {|value| value.strip }.uniq.join(',') #remove duplicates 																		#rebuild the string
		elsif value.is_a?(Array)
			#make sure only Integers or Strings are in the Array
			value.each do |val|
				unless val.is_a?(String) || val.is_a?(Integer)
					puts "Error: Invalid value detected in RestOptions argument. Expected a String, " +
					     "Integer, or Array of Strings and/or Integers.\nInstead got a(n) => #{val.class} " +
					     "at index #{value.find_index(val)} ...Exiting"
					exit
				end
			end
			#build clean string from array
			str = value.map { |value| value.to_s.strip }.join(',')
		end
		return str 
	end

	public

	def add_option(field_name,field_value)
		field = clean(field_name)
		value = clean(field_value)
		if field && value && @options.empty?
			@options += '?' + field + '=' + value
		elsif field && value && !@options.empty?
			@options += '&' + field + '=' + value
		end
	end	

	def remove_option(field_name,field_value)
		value = clean(field_name) + '=' + clean(field_value)
		unless @options.empty?
			if @options.include?("?#{value}")
				@options.gsub("?#{value}",'')
			elsif @options.include?("&#{value}")
				@options.gsub("&#{value}",'')
			else
				warn "#{value} parameter not found. Nothing to remove." 
			end
		end
	end

	def clear
		@options = ''
	end

	def clear_options
		clear
	end

	def get_options
		@options
	end

end