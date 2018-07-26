class Finder

	def initialize
	end

	def evaluate(*args)

		return if args.empty?
		operand1 = args[0]
		operator = args[1]
		operand2 = args[2]
		result   = nil

		unless operator.class.to_s == 'Regexp' || operand2.class.to_s == 'Array'
			if operand1.class != operand2.class
				# Try to recover if possible.
				numeric_regex = %r{^\d+$}
				float_regex   = %r{^\d+\.\d+$}
				if numeric_regex.match(operand1.to_s) &&
					numeric_regex.match(operand2.to_s)
					# Both are numbers: Convert to integers for comparison
					operand1 = operand1.to_i
					operand2 = operand2.to_i
				elsif float_regex.match(operand1.to_s) &&
					   float_regex.match(operand2.to_s)
					# Both are floats: Convert to Floats for comparison
					operand1 = operand1.to_f
					operand2 = operand2.to_f
				else
					msg = "Type Error: Cannot compare Integer to String\n" +
							"\t#{operand1} <=> #{operand2}"
					puts msg
					#return
				end
			end
		end

		if operator.eql?("!=")
			result = operand1 != operand2 ? true : false
		elsif operator.eql?("<")
			result = operand1 < operand2 ? true : false
		elsif operator.eql?(">")
			result = operand1 > operand2 ? true : false
		elsif operator.eql?("==")
			result = operand1 == operand2 ? true : false
		elsif operator.eql?("in")
			result = operand2.include?(operand1) ? true : false
		elsif operator.eql?("not in")
			result = !operand2.include?(operand1) ? true : false
		elsif operator.is_a?(Regexp)
			result = operator.match(operand1) ? true : false
		else
			puts 'Unknown error in evaluator.'
		end
		result
	end

	def find_matches(expressions,objects=[])

		matches = []
		boolean_operator_lookup = {
			'and' => '&&',
			'or'  => '||'
		}

		objects.each do |object|
			completed_expression = []
			expressions.each do |exp|
				if exp == 'and' || exp == 'or'
					completed_expression << boolean_operator_lookup[exp]
					next
				end
				preceding_parentheses = exp[0]
				# Capture method to be called on object
				method_name = exp[1]
				# Validate method name
				unless object.respond_to?(method_name.to_sym)
					puts "Invalid column name #{method_name}"
					return
				end
				# Self explanatory
				comparison_operator = exp[2]
				# Capture value to be compared against method call's return value
				value = exp[3]
				trailing_parentheses = exp[4]
				# Capture method call return value
				obj_attr_data = object.send(method_name.to_sym)
				# Extract regex str and evaluate against object data
				if comparison_operator.is_a?(Hash)
					comparison_operator = comparison_operator['regex']
					obj_attr_data = object.send(method_name.to_sym).to_s
					value = value.to_s
				end
				if comparison_operator == 'in' || comparison_operator == 'not in'
					obj_attr_data = object.send(method_name.to_sym).to_s
				end
				# Evaluate expression
				result = evaluate(obj_attr_data,comparison_operator,value)
				# Format expressions
				exp_str = "#{preceding_parentheses}#{result}#{trailing_parentheses}"
				completed_expression << exp_str
			end
			# Convert independent expressions to one string => e.g "(true && false) || true"
			completed_expression = completed_expression.join(' ')
			# Grab object if it meets search criteria
			# SECURITY: This is what a completed_expression
			# would look like BEFORE being passed to eval: "(true && false) || true" => true
			result = eval(completed_expression)
			matches << object if result == true
        end
        matches
	end
	alias :find_match :find_matches
end

