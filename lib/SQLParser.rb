module SQLParser
	
	def self.parse_query(original_query)

		# Trim query string
		original_query.strip!
		unless /^where/i.match(original_query)
			puts "No where clause detected."
			return
		end

		# Captures <field|comparison operator|value> expressions e.g name="joe schmoe's deli" or id=5
		string_finder = Regexp.new("(([a-zA-Z_])(=)([\"\'])([\\w+\\s+\'?\"?]+)([\"\']))")
		
		expressions = []
		criteria    = []

		# make a working copy of the query
		query = original_query.dup.downcase
		query.gsub!(/\s*where\s*/,'')
		query.gsub!('<>','!=')

		# ORDER IS IMPORTANT: putting '=' first will break
		# string_regex and numeric_regex parsing of '!=' operator
		comp_operators = [ '!=', '<', '>', '=', 'like' ]

		# Trim spaces between operators and operands
		comp_operators.each do |op|
			regex = Regexp.new("\\s+#{op}\\s+")
			query.gsub!(regex,op)
		end
		
		# Temporarily replace spaces with asterisks before splitting 
		# query string by space
		if string_finder.match(query)
			data = string_finder.match(query)[0]
			replacement = data.gsub(' ','******')
			query.gsub!(data,replacement)
		end

		# Split query copy by space
		criteria = query.split(/\s+/)

		# check for missing operators
		query_copy = query.gsub(/(and|or)/,'')
		query_expressions = query_copy.split(/\s+/)
		query_expressions.each.with_index do |exp,i|
			operator_found = false
			comp_operators.each do |op|
				operator_found = true if exp.include?(op)
			end
			unless operator_found
				abort("Syntax Error: Missing comparison operator in expression: #{exp} -> ??? <- #{query_expressions[i+1]}")
			end
		end

		# Restore string arguments to their original form
		criteria.each { |val| val.gsub!('******',' ')}

		# Parse query: Build array of expressions
		while next_value = criteria.shift
			if next_value == 'and' || next_value == 'or'
				expressions << next_value
				next
			end

			comp_operators.each do |op|
				if next_value.include?(op)
					method_name = nil
					value = nil
					string_regex  = Regexp.new("(.*)(#{op})(([\"\'])([\\w+\\s+\'?\"?\)?]+)([\"\']))") # => catches e.g. name="john doe's pub is for bums"
					numeric_regex = Regexp.new("^(.*)(#{op})([0-9]+\\)?)$") # catches id = 5 or id = 5) <- grouped expressions
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
							end
						end

						# Check for 'like' clause in value
						like_clause_regex = %r{(\w+)((?:like))(\"|\')(%?)(.*)(%?)(\"|\')}
						if like_clause_regex.match(next_value)
							match = like_clause_regex.match(next_value)
							method_name = match[1]
							value = match[5]
							regex_str = match[4].empty? ? value : "(.*)(#{value})"
							regex_str += match[6].empty? ? '' : '(.*)'
							#regex_lookup = { 'regex' => regex_str }

							# Empty out value since we are building a regex check
							# End result should look like this => [ 'name', { regex => "(.*)(#{value})(.*)" }, '' ]
							op = "/#{regex_str}/"
							
						end
					elsif numeric_regex.match(next_value) # Operand is a numeric value
						match = numeric_regex.match(next_value)

						# Extract method name to be called on file object
						method_name = match[1]

						# Extract the value the file method call return value 
						# will be compared to
						value = match[3]
					else # Regex match fail => Most likely due to missing closing quote
						index = original_query.index(next_value)
						abort("Query parsing error. Possible missing quotes.\n 
							   CAPTURED => #{next_value.inspect}\n 
							   ORIGINAL QUERY => #{query}")
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