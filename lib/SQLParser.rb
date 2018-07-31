require_relative 'MyLogger'
class SQLParser

	include Logging

	# ORDER IS IMPORTANT: putting '=' first will break
	# string_regex and numeric_regex parsing of '!=' operator
	VALID_COMPARISON_OPERATORS = [ 'between', '!=', '<=', '>=', '<', '>', '=', 'not like', 'like', 'not in', 'in' ]

	# => catches id in (1,2,3,4)
	@@in_clause_regex = %r{
		([\(\s]*)(\w+)
		(--\[:space:\]--)?(in|not\s*in)(--\[:space:\]--)?
		(\()(.*[^\)\s])(\))([\)\s]*)
	}x

	# catches id between 9 and 17
	@@between_clause_regex = %r{
		([\(\s]*)(\w+)
		(--\[:space:\]--|\ )*(between)(--\[:space:\]--|\ )*
		("|')?(\w+)(\k<6>)?
		(--\[:space:\]--|\ )*
		(and)
		(--\[:space:\]--|\ )*
		("|')?(\w+)(\k<12>)?
		([\)\s]*)
	}x

	@@quoted_number_regex = %r{
		^([\s\(]*)(\w+)
		(--\[:space:\]--)?(=)(--\[:space:\]--)?
		(\"?\'?)(?:([0-9]+)(\6))
		([\s\)]*)$
	}x

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
			logger.error( 'The case_sensitive= method only accepts true or false. Default is false')
			return
		end
		@case_sensitivity = val.eql?('true') ? nil : Regexp::IGNORECASE
	end

	def parse_query(original_query)

		# Trim query string
		original_query.strip!
		unless /^where/i.match(original_query)
			logger.error('No where clause detected.')
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
			logger.error(msg)
			return
		end

		expressions = []
		criteria    = []

		# make a working copy of the query
		query = original_query.dup#.downcase
		query.gsub!(/^\s*where\s*/,'')
		query.gsub!('<>','!=')

		# Capture order which operators appear in query
		ordered_operators = []
		VALID_COMPARISON_OPERATORS.each do |op|
			index = query.index(op)
			next unless index
			ordered_operators << [index,op]
		end
		ordered_operators.sort_by! { |index,operator| index }

		# Trim spaces between operators and operands
		ordered_operators.each do |i,op|
			regex = Regexp.new("\\s+#{op}\\s+", Regexp::IGNORECASE)
			if op.eql?("between") && query.include?("between")
				match = @@between_clause_regex.match(query)
				start_paren = match[1]
				method_name = match[2]
				operator    = match[4].to_s.downcase
				start_range = match[7]
				end_range   = match[13]
				end_paren   = match[15]
				repl_str = "#{start_paren}#{method_name}" +
						   "--[:space:]--#{operator}--[:space:]--" +
						   "#{start_range}--[:space:]----[:BetweenANDoperator:]----[:space:]--#{end_range}#{end_paren}"
				query.gsub!(@@between_clause_regex,repl_str)
			else
				query.gsub!(regex,"--[:space:]--#{op.downcase}--[:space:]--")
			end
		end

		query_copy = query.gsub(/\s+and\s+/,'--[:ANDoperator:]--').gsub(/\s+or\s+/,'--[:ORoperator:]--')
		query_expressions = query_copy.split(/(--\[:ANDoperator:\]--|--\[:ORoperator:\]--)/)

		# Check for missing operators
		query_expressions.each.with_index do |exp,i|

			next if exp == "--[:ANDoperator:]--" || exp == "--[:ORoperator:]--"

			if @@quoted_number_regex.match(exp)
				# Remove quotes from numeric operands
				exp.gsub!(/("|')/,'')
			end
			operator_found = false
			VALID_COMPARISON_OPERATORS.each do |op|
				operator_found = true if exp.include?(op)
			end
			unless operator_found
				logger.error("Syntax Error: Missing comparison operator in expression: #{exp} -> ??? <- #{query_expressions[i+1]}")
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

			next_value.gsub!('--[:BetweenANDoperator:]--','and') if next_value.include?('--[:BetweenANDoperator:]--')

			ordered_operators.each do |i,op|

				next_value.gsub!(/not\s+like/,'not like') if op.eql?('not like')
				next_value.gsub!(/not\s+in/,'not in') if op.eql?('not in')

				# => catches e.g. (name="john doe's pub is for bums")
				string_regex = %r{
					([\s\(]*)(\w+)
					(--\[:space:\]--)?(#{op})(--\[:space:\]--)?
					(([\"\'])([\w\s\%\.\\\_?\'?\"?\)?]+)(\7)([\s\)]*))
				}x

				# => catches id = 5 or id = 5) <- grouped expressions
				numeric_regex = %r{
					^([\s\(]*)(\w+)
					(--\[:space:\]--)?(#{op})(--\[:space:\]--)?
					([0-9]+)([\s\)]*)$
				}x

				if next_value.include?(op)
					p next_value
					preceding_parentheses = nil
					method_name           = nil
					operator              = nil
					value                 = nil
					trailing_parentheses  = nil

					if @@between_clause_regex.match(next_value)
						match = @@between_clause_regex.match(next_value)
						p match

						preceding_parentheses = match[1]
						method_name = match[2]
						operator = match[4]
						val1 = match[7]
						val2 = match[13]
						value = [val1,val2]
						trailing_parentheses = match[15]
					elsif string_regex.match(next_value) # Operand is a string value
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
								logger.error(msg)
								return
							end
						end

						# Validate operator
						unless operator_valid?(op)
							logger.error("Syntax Error: Invalid operator => #{op}")
							return
						end

						# CONVERT "LIKE" CLAUSE INTO A REGEX STRING +> name not like "%joe's deli_%" -> {"regex"=>"^(?!(.*)joe's deli.)$"}
						# Check for 'like' clause in value and build regex to be used against object attributes
						# Checks for % and _ in clause while ignoring escaped \% \_:
						like_clause_regex = %r{([\(\s]*)(\w+)(--\[:space:\]--)*(\s*not\s*)?(--\[:space:\]--)*((?:like))(--\[:space:\]--)*(?:'((?:[^\\']|\\.)*)'|"((?:[^\\"]|\\.)*)")([\s\)]*)}
						if like_clause_regex.match(next_value)
							match = like_clause_regex.match(next_value)
							p match
							preceding_parentheses = match[1].to_s
							method_name = match[2]
							negated = match[4]

							str = match[8]
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
					elsif @@in_clause_regex.match(next_value)
						# Extract data in query 'where id in (1,2,3)' => method_name = id | value = "1,2,3"
						match = @@in_clause_regex.match(next_value)
						preceding_parentheses = match[1].to_s
						method_name =  match[2]
						operator = match[4]
						nested_quote_regex = %r{('|")(.*)(\1)}
						value = match[7].to_s.split(',').map do |val|
							if nested_quote_regex.match(val)
								val = nested_quote_regex.match(val)[2]
							end
							val
						end
						trailing_parentheses = match[9].to_s
					elsif numeric_regex.match(next_value) # Operand is a numeric value
						match = numeric_regex.match(next_value)
						p match
						preceding_parentheses = match[1].to_s
						method_name = match[2]
						operator = match[4]
						value = match[6]
						trailing_parentheses = match[7].to_s
					else # Regex match fail => Most likely due to missing closing quote or bad operator
						index = original_query.index(next_value)

						msg = "SQL parsing error: "
						if !operator.is_a?(Hash)
							unless VALID_COMPARISON_OPERATORS.include?(operator)
								msg += "invalid operator #{operator}"
							end
						end
						msg = "#{msg}\n" +
							 "CAPTURED => #{next_value.inspect}\n" +
							 "ORIGINAL QUERY => #{original_query}"
						logger.error(msg)
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
					#p exp_data
					# Store extracted expression for use in filter_files method call
					expressions << exp_data
					p expressions
					break
				end
			end
		end
		expressions
	end
	alias :parse :parse_query
end