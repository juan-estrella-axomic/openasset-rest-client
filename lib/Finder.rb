class Finder

    include Logging

    def initialize
    end

    def evaluate(*args)

        return if args.empty?

        numeric_regex = %r{^\d+$}
        float_regex   = %r{^\d+\.\d+$}
        operand1      = args[0]
        operator      = args[1]
        operand2      = args[2]
        result        = nil
        msg           = nil


        unless operator.class.to_s == 'Regexp'
            if operand1.class != operand2.class
                # Try to recover if possible.
                if operand2.is_a?(Array)
                    if numeric_regex.match(operand1.to_s)
                        operand2 = operand2.map(&:to_i)
                    elsif float_regex.match(operand1.to_s)
                        operand2 = operand2.map(&:to_f)
                    else
                        msg = "Unknown error comparing #{operand1.class} to #{operand2.class}" +
                                "\t#{operand1} <=> #{operand2}"
                    end
                elsif numeric_regex.match(operand1.to_s) &&
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
                    msg = "Type Error: Cannot compare #{operand1.class} to #{operand2.class}\n" +
                            "\t#{operand1} <=> #{operand2}"
                end
            end
        end

        if msg
            logger.error(msg)
            return
        end

        if operator.eql?("!=")
            result = operand1 != operand2 ? true : false
        elsif operator.eql?("<")
            result = operand1 < operand2 ? true : false
        elsif operator.eql?("<=")
            result = operand1 <= operand2 ? true : false
        elsif operator.eql?(">=")
            result = operand1 >= operand2 ? true : false
        elsif operator.eql?(">")
            result = operand1 > operand2 ? true : false
        elsif operator.eql?("==")
            result = operand1 == operand2 ? true : false
        elsif operator.eql?("between")
            val1 = operand2[0]
            val2 = operand2[1]
            result = (operand1 >= val1 && operand1 <= val2) ? true : false
        elsif operator.eql?("in")
            result = operand2.include?(operand1) ? true : false
        elsif operator.eql?("not in")
            result = !operand2.include?(operand1) ? true : false
        elsif operator.is_a?(Regexp)
            result = operator.match(operand1) ? true : false
        else
            logger.fatal('UNKNOWN ERROR IN EVALUATOR.')
            abort
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
                    puts "Invalid column name #{method_name.inspect}"
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

