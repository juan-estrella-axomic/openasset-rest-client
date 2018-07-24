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
		
		if operator.eql?("!=")
			result = operand1 != operand2 ? true : false
		elsif operator.eql?("<")
			result = operand1 < operand2 ? true : false
		elsif operator.eql?(">")
			result = operand1 > operand2 ? true : false
		elsif operator.eql?("==")
			result = operand1 == operand2 ? true : false
		elsif operator.eql?("in")
			operand2 = operand2.split(',').map(&:to_s)
			result = operand2.include?(operand1) ? true : false
		elsif operator.is_a?(Regexp)
			result = operator.match(operand1) ? true : false
		else 
			abort('Unknown error in evaluator.')
		end
		result
	end

	def self.find_files(expressions,files=[])
		matches = []
		boolean_operator_lookup = {
			'and' => '&&',
			'or'  => '||'
		}
		expressions = SQLParser.parse_query(expressions) ################################################3
		#files.each do |file| #########################################################3
			completed_expression = []

			expressions.each do |exp|

				if exp == 'and' || exp == 'or'
					completed_expression << boolean_operator_lookup[exp]
					next
				end

				# Capture method to be called on files object
				method_name = exp[0]

				# Validate method name
				# abort("Invalid operand #{method_name}") unless file.respond_to?(method_name.to_sym) #####################################333

				# Self explanatory
				comparison_operator = exp[1]

				# Capture value to be compared against method call's return value
				value = exp[2]

				# Capture method call return value
				file_attr_data = method_name.gsub('(','')
				#file_attr_data = file.send(method_name.gsub('(',''))

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
				if comparison_operator.is_a?(Hash)
					regex_str = comparison_operator['regex']
					comparison_operator = Regexp.new(regex_str)
					file_attr_data = file.send(method_name.to_sym).to_s	
					value = value.to_s
				end

				if comparison_operator == 'in'
					#file_attr_data = file.send(method_name.to_sym).to_s
					file_attr_data = method_name.to_s ##############################################################
					value = value.to_s
				end

				# Evaluate expression
				result = evaluate(file_attr_data,comparison_operator,value)
	
				# Format expression and insert
				#s = "#{preceding_parenthesis}#{file_attr_data} #{comparison_operator} #{value}#{trailing_parenthesis}"
				#puts "S Value => #{s}"
				exp_str = "#{preceding_parenthesis}#{result}#{trailing_parenthesis}"
				#puts "Expression => #{exp_str}"
				completed_expression << exp_str
			end

			# Convert independent expressions to one string => e.g "(true && false) || true"
			completed_expression = completed_expression.join(' ')

			# Grab file if it meets search criteria
			# SECURITY: This is what a completed_expression 
			# BEFORE being passed to eval would look like: "(true && false) || true" => true
			result = eval(completed_expression) 
			matches << file if result == true
        #end ##################################################################################3
        matches
    end
    
end
FileFinder.find_files(%q{where id="5" and name = "joe's pub" or name like "joe " or id in (1,2,3)})
