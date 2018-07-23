require_relative 'SQLParser'

module FileFinder

	def self.evaluate(operand1=nil,operator=nil,operand2=nil)
		result = nil
		unless operand1.class == operand2.class
			# Try to recover if possible.
			numeric_regex = %r{^\d+$}
			if numeric_regex.match(operand1.to_s) && 
				numeric_regex.match(operand2.to_s)
				# Both are numbers: Convert to integers for comparison
				operand1 = operand1.to_i
				operand2 = operand2.to_i
			else
				msg = "Type Error: Cannot compare Integer to String\n" +
					     "\t#{operand1} <-> #{operand2}"
				abort(msg)
			end
		end
		result = nil
		case operator
		when "!="
			result = operand1 != operand2 ? true : false
		when "<"
			result = operand1 < operand2 ? true : false
		when ">"
			result = operand1 > operand2 ? true : false
		when "=="
			result = operand1 == operand2 ? true : false
		else 
			result = operator
		end
		result
	end

	def self.find_files(expressions,files=[])
		matches = []
		files.each do |file|
			completed_expression = []

			expressions.each do |exp|

				if exp == 'and' || exp == 'or'
					completed_expression << exp
					next
				end

				# Capture method to be called on files object
				method_name = exp[0]

				# Self explanatory
				comparison_operator = exp[1]

				# Capture value to be compared against method call's return value
				value = exp[2]

				# Capture method call return value
				file_attr_data = method_name.gsub('(','')#file.send(method_name.gsub('(',''))

				# Capture any preceding parentheses: Later used to retain order of operations 
				preceding_parenthesis = /\(+/.match(method_name) #method_name[0] == '(' ? '(' : ''
				# puts method_name
				# puts "Preceding parentheses => #{preceding_parenthesis}\n"

				# Capture any trailing parentheses: Later used to retain order of operations
				trailing_parenthesis = /\)+/.match(value) #value.to_s[-1] == ')' ? ')' : ''
				# puts value
				# puts "Trailing parentheses #{trailing_parenthesis}\n"

				# Capture numeric operands even if followed by parentheses
				numeric_regexp = %r{^\d+\)*$}

				if numeric_regexp.match(value)  # Operand is a numric value
					# Extract numeric operand value then cast it to an integer
					value = value.to_s.gsub(')','').to_i			
				end

				# Extract regex str and evaluate against file data
				result = comparison_operator
				if comparison_operator.is_a?(Hash)
					regex_str = comparison_operator['regex']
					value = file.send(method_name.to_sym)
					result = /#{regex_str}/.match("#{value}")
					result = result.nil? ? false : true
					comparison_operator = result
					method_name = ''
					value = ''
				end

				# Evaluate expression
				result = evaluate(file_attr_data,result,value)
	
				# Format expression and insert
				#s = "#{preceding_parenthesis}#{file_attr_data} #{comparison_operator} #{value}#{trailing_parenthesis}"
				#puts "S Value => #{s}"
				exp_str = "#{preceding_parenthesis}#{result}#{trailing_parenthesis}"
				#puts "Expression => #{exp_str}"
				completed_expression << exp_str
			end

			# Convert independent expressions to one string => e.g "(true and false) or true"
			completed_expression = completed_expression.join(' ')

			# Grab file if it meets search criteria
			result = eval(completed_expression) # (true and false) or true => true
			matches << file if result == true
        end
        matches
    end
    
end
