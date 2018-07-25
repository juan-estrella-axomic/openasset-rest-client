class SQLParser

	# ORDER IS IMPORTANT: putting '=' first will break
	# string_regex and numeric_regex parsing of '!=' operator
	VALID_COMPARISON_OPERATORS = [ '!=', '<', '>', '=', 'not like', 'like', 'not in', 'in' ]

	attr_reader :case_sensitivity

	private
	def initialize(case_sensitive=false)
		@case_sensitivity = case_sensitive ? nil : Regexp::IGNORECASE
	end


	def operator_valid?(operator)
		VALID_COMPARISON_OPERATORS.include?(operator) ? true : false
	end

	public
	def case_sensitivity=(val)
		val = val.to_s.strip.downcase
		unless val.eql?('true') || val.eql?(false)
			puts 'The case_sensitive= method only accepts true or false. Default is false'
			return
		end
		@case_sensitivity = val.eql?('true') ? nil : Regexp::IGNORECASE
	end

	def parse_query(original_query)

		# Trim query string
		original_query.strip!
		unless /^where/i.match(original_query)
			puts "No where clause detected."
			return
		end

		# Check for mismatched partheses
		open_paren_count   = original_query.count('(')
		closed_paren_count = original_query.count(')')
		unless open_paren_count == closed_paren_count
			msg = 'Syntax Error: '
			if open_paren_count > closed_paren_count # ( ( )
				msg += "ended query with unmatched parenthesis => #{original_query}"
			else # ( ) )
				msg += "unmatched close parenthesis in query => #{original_query}"
			end
			puts msg
			return
		end

		expressions = []
		criteria    = []

		# make a working copy of the query
		query = original_query.dup#.downcase
		query.gsub!(/^\s*where\s*/,'')
		query.gsub!('<>','!=')

		# Trim spaces between operators and operands
		VALID_COMPARISON_OPERATORS.each do |op|
			regex = Regexp.new("\\s+#{op}\\s+", Regexp::IGNORECASE)
			query.gsub!(regex,"--[:space:]--#{op.downcase}--[:space:]--")
		end

		query_copy = query.gsub(/\s+and\s+/,'--[:ANDoperator:]--').gsub(/\s+or\s+/,'--[:ORoperator:]--')
		query_expressions = query_copy.split(/(--\[:ANDoperator:\]--|--\[:ORoperator:\]--)/)

		# Check for missing operators
		query_expressions.each.with_index do |exp,i|

			next if exp == "--[:ANDoperator:]--" || exp == "--[:ORoperator:]--"
			quoted_number_regex = %r{^([\s\(]*)(\w+)(--\[:space:\]--)?(=)(--\[:space:\]--)?(\"?\'?)(?:([0-9]+)(\6))([\s\)]*)$}
			if quoted_number_regex.match(exp)
				# Remove quotes from numeric operands
				exp.gsub!(/("|')/,'')
			end
			operator_found = false
			VALID_COMPARISON_OPERATORS.each do |op|
				operator_found = true if exp.include?(op)
			end
			unless operator_found
				#abort("Syntax Error: Missing comparison operator in expression: #{exp} -> ??? <- #{query_expressions[i+1]}")
				puts "Syntax Error: Missing comparison operator in expression: #{exp} -> ??? <- #{query_expressions[i+1]}"
				return
			end
		end

		criteria = query_expressions
		exp_data = []

		# Parse query: Build array of expressions
		while next_value = criteria.shift

			if next_value == '--[:ANDoperator:]--'
				expressions << 'and'
				next
			elsif next_value == '--[:ORoperator:]--'
				expressions << 'or'
				next
			end

			VALID_COMPARISON_OPERATORS.each do |op|
				next_value.gsub!(/not\s+like/,'not like') if op.eql?('not like')
				next_value.gsub!(/not\s+in/,'not in') if op.eql?('not in')

				if next_value.include?(op)
					preceding_parentheses = nil
					method_name           = nil
					operator              = nil
					value                 = nil
					trailing_parentheses  = nil

					# => catches e.g. (name="john doe's pub is for bums")
					string_regex = %r{([\s\(]*)(\w+)(--\[:space:\]--)?(#{op})(--\[:space:\]--)?(([\"\'])([\w\s\%\\\_?\'?\"?\)?]+)(\7)([\s\)]*))}

					# => catches id = 5 or id = 5) <- grouped expressions
					numeric_regex = %r{^([\s\(]*)(\w+)(--\[:space:\]--)?(#{op})(--\[:space:\]--)?([0-9]+)([\s\)]*)$}

					# => catches id in (1,2,3,4)
					in_clause_regex = %r{([\(\s]*)(\w+)(--\[:space:\]--)?(in|not\s*in)(--\[:space:\]--)?(\()(.*[^\)\s])(\))([\)\s]*)}

					if string_regex.match(next_value) # Operand is a string value
						match = string_regex.match(next_value)
						preceding_parentheses = match[1]
						method_name = match[2]
						operator = match[4]
						value = match[8].to_s
						trailing_parentheses = match[10].to_s

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
								puts msg
								return
							end
						end

						# Validate operator
						unless operator_valid?(op)
							puts "Syntax Error: Invalid operator => #{op}"
							return
						end

						# CONVERT "LIKE" CLAUSE INTO A REGEX STRING +> name not like "%joe's deli_%" -> {"regex"=>"^(?!(.*)joe's deli.)$"}
						# Check for 'like' clause in value and build regex to be used against object attributes
						# Checks for % and _ in clause while ignoring escaped \% \_:
						like_clause_regex = %r{([\(\s]*)(\w+)(--\[:space:\]--)?(\s*not\s*)?(--\[:space:\]--)?((?:like))(--\[:space:\]--)?(?:'((?:[^\\']|\\.)*)'|"((?:[^\\"]|\\.)*)")([\s\)]*)?}
						if like_clause_regex.match(next_value)
							match = like_clause_regex.match(next_value)

							preceding_parentheses = match[1].to_s
							method_name = match[2]
							negated = match[4]

							str = match[9]
							value = str.dup
							str.gsub!(/(?<!\\)%/,'(.*)') # handles % sql wildcard character
							str.gsub!(/(?<!\\)_/,'.') # handles _ sql wildcard character

							regex_string = '^'
							if negated
								regex_string += "(?!#{str})"
							else
								regex_string += str
							end
							regex_string += '$'

							regex = Regexp.new(regex_string, @case_sensitivity)
							operator = { 'regex' => regex }
							trailing_parentheses = match[10].to_s
						end
					elsif in_clause_regex.match(next_value)
						# Extract data in query 'where id in (1,2,3)' => method_name = id | value = "1,2,3"
						match = in_clause_regex.match(next_value)
						preceding_parentheses = match[1].to_s
						method_name =  match[2]
						operator = match[4]
						value = match[7].to_s.split(',')
						trailing_parentheses = match[9].to_s
					elsif numeric_regex.match(next_value) # Operand is a numeric value
						match = numeric_regex.match(next_value)
						preceding_parentheses = match[1].to_s
						method_name = match[2]
						operator = match[4]
						value = match[6]
						trailing_parentheses = match[7].to_s
					else # Regex match fail => Most likely due to missing closing quote or bad operator
						index = original_query.index(next_value)

						msg = "Query parsing error: "
						if !operator.is_a?(Hash)
							unless VALID_COMPARISON_OPERATORS.include?(operator)
								msg += "invalid operator #{operator}"
							end
						end
						puts("#{msg}\n
							   CAPTURED => #{next_value.inspect}\n
							   ORIGINAL QUERY => #{original_query}")
							   return
					end

					# Replace SQL style operator with valid comparison operator
					operator = operator.eql?("=") ? "==" : operator
					method_name.gsub!(/--\[:space:\]--/,'')
					exp_data = [
						preceding_parentheses,
						method_name,
						operator,
						value,
						trailing_parentheses
					]
					# Store extracted expression for use in filter_files method call
					expressions << exp_data
					break
				end
			end
		end
		expressions
	end
	alias :parse :parse_query

end

sql = SQLParser.new
sql.parse_query(%q{where id="5" and name = "joe's pub" or name like "joe " or id in (1,2,3)})