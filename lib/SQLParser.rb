module SQLParser

	# ORDER IS IMPORTANT: putting '=' first will break
	# string_regex and numeric_regex parsing of '!=' operator
	VALID_COMPARISON_OPERATORS = [ '!=', '<', '>', '=', 'like', 'in' ]
	
	def self.operator_valid?(operator)
		VALID_COMPARISON_OPERATORS.include?(operator) ? true : false
	end
	
	def self.parse_query(original_query)

		# Trim query string
		original_query.strip!
		unless /^where/i.match(original_query)
			puts "No where clause detected."
			return
		end

		# Captures <field|comparison operator|value> expressions e.g name="joe schmoe's deli" or id=5
		string_finder = Regexp.new(/([a-zA-Z_]+)(=)([\"?\'?])(?:([\w\s(\"|\')]+)(\3))/)
		
		expressions = []
		criteria    = []

		# make a working copy of the query
		query = original_query.dup.downcase
		query.gsub!(/\s*where\s*/,'')
		query.gsub!('<>','!=')
		
		puts query

		# Trim spaces between operators and operands
		VALID_COMPARISON_OPERATORS.each do |op|
			regex = Regexp.new("\\s+#{op}\\s+")
			query.gsub!(regex,op)
			puts query
		end

		# IMPORTANT: Remove quotes from numeric operands otherwise parser breaks later on
		#.gsub!(/^(\w+)(=)(\"?\'?)(?:([0-9]+)(\3))$/,$1+$2+$4) # id="5" => id=5
		
		# Temporarily replace spaces with asterisks before splitting 
		# query string by space
		# if string_finder.match(query)
		# 	data = string_finder.match(query)[0]
		# 	replacement = data.gsub(' ','[:space:]')
		# 	query.gsub!(data,replacement)
		# end

		# Split query copy by space
		#criteria = query.split(/\s+/)

		# check for missing operators
		query_copy = query.gsub(/\s+and\s+/,'--[:ANDoperator:]--').gsub(/\s+or\s+/,'--[:ORoperator:]--')

		puts query_copy
	
		#query_copy = query_copy.gsub('******',' ')
		query_expressions = query_copy.split(/(--\[:ANDoperator:\]--|--\[:ORoperator:\]--)/)
		p query_expressions
		
		query_expressions.each.with_index do |exp,i|

			next if exp == "--[:ANDoperator:]--" || exp == "--[:ORoperator:]--"
			
			if /^(\w+)(=)(\"?\'?)(?:([0-9]+)(\3))$/.match(exp)
				# IMPORTANT: Remove quotes from numeric operands otherwise parser breaks later on
				exp.gsub!(/^(\w+)(=)(\"?\'?)(?:([0-9]+)(\3))$/,$1+$2+$4) # id="5" => id=5
			end
			puts exp
			operator_found = false
			VALID_COMPARISON_OPERATORS.each do |op|
				operator_found = true if exp.include?(op) || op.is_a?(Hash)
			end
			unless operator_found
				#abort("Syntax Error: Missing comparison operator in expression: #{exp} -> ??? <- #{query_expressions[i+1]}")
				abort("Syntax Error: Missing comparison operator in expression: #{exp} -> ??? <- #{query_expressions[i+1]}")
			end
		end
		criteria = query_expressions

		# Restore string arguments to their original form
		#criteria.each { |val| val.gsub!('******',' ')}
		#criteria = query_copy.query_copy = query.gsub(/\s+and\s+/,'--[:ANDoperator:]--').gsub(/\s+or\s+/,'--[:ORoperator:]--')

		# Parse query: Build array of expressions
		while next_value = criteria.shift
			if next_value == 'and' || next_value == 'or'
				expressions << next_value
				next
			end

			VALID_COMPARISON_OPERATORS.each do |op|
				if next_value.include?(op)
					method_name = nil
					value = nil
					string_regex  = Regexp.new("(.*)(#{op})(([\"\'])([\\w+\\s+\'?\"?\)?]+)([\"\']))") # => catches e.g. name="john doe's pub is for bums"
					numeric_regex = Regexp.new("^(.*)(#{op})([0-9]+\\)?)$") # catches id = 5 or id = 5) <- grouped expressions
					in_clause_regex = %r{(\w+)((?:in))(\()(.*)(\))}
					if string_regex.match(next_value) # Operand is a string value
						match = string_regex.match(next_value)

						# Extract method name to be called on file object
						method_name = match[1]

						# Extract the value the file method call return value 
						# will be compared to
						value = match[3]

						# Grab first and last char of expression
						first_char = value[0]
						last_char = value[-1]

						# Check for mismatched quotes
						if first_char.eql?('"') || first_char.eql?("'")
							unless first_char == last_char
								index = original_query.index(next_value) + next_value.length
								q = original_query
								q.insert(index," <= RIGHT HERE ***")
								msg = "Syntax Error: Mismatched quotes in query: #{q}"
								abort(msg)
							end
						end

						# Validate operator
						unless operator_valid?(op) || operator.is_a?(hash) # <= used for LIKE clause
							abort("Syntax Error: Invalid operator => #{op}")
						end

						# Check for 'like' clause in value
						like_clause_regex = %r{(\w+)((?:like))(\"|\')(%?)(.*)(%?)(\"|\')}
						
						if like_clause_regex.match(next_value)
							match = like_clause_regex.match(next_value)
							method_name = match[1]
							value = match[5]
							regex_str = match[4].empty? ? "^#{value}" : "(.*)(#{value})"
							regex_str += match[6].empty? ? '$' : '(.*)'
							op = { 'regex' => "/#{regex_str}/" }
						end
					elsif in_clause_regex.match(next_value)
						# Extract data in query 'where id in (1,2,3)' => method_name = id | value = "1,2,3"
						match = in_clause_regex.match(next_value)
						method_name = match[1]
						value = match[4]
						op = 'in'
					elsif numeric_regex.match(next_value) # Operand is a numeric value
						match = numeric_regex.match(next_value)

						# Extract method name to be called on file object
						method_name = match[1]

						# Extract the value the file method call return value 
						# will be compared to
						value = match[3]
					else # Regex match fail => Most likely due to missing closing quote
						index = original_query.index(next_value)
						#query = query.gsub('******',' ')
						abort("Query parsing error. Possible missing quotes.\n 
							   CAPTURED => #{next_value.inspect}\n 
							   ORIGINAL QUERY => #{original_query}")
					end 
					
					# Replace SQL style operator with valid comparison operator 
					op = op.eql?("=") ? "==" : op

					# Store extracted expression for use in filter_files method call
					expressions << [ method_name, op, value ]
					break
				end
			end
		end
		expressions
    end
    
end

SQLParser.parse_query(%q{where id="5" and name = "joe's pub" or name like "joe " or id in (1,2,3)})