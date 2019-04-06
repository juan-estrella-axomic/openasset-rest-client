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
                    msg = "Type Error: Cannot compare #{operand1.class} " \
                          "to #{operand2.class}\n\t#{operand1} <=> #{operand2}"
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
            val1 = operand2[0].to_s
            val2 = operand2[1].to_s
            regex = %r{^\d+(?:\.\d+)?$} # checks numeric values
            v1_is_num = !!val1.match(regex)
            v2_is_num = !!val2.match(regex)
            mismatch = v1_is_num ^ v2_is_num
            if mismatch
                logger.error("Can't compare #{val1} to #{val2}")
                return
            end
            if v1_is_num
                val1 = val1.to_f
                val2 = val2.to_f
            end
            result = (operand1 >= val1 && operand1 <= val2) ? true : false
        elsif operator.eql?("in")
            result = operand2.include?(operand1) ? true : false
        elsif operator.eql?("not in")
            result = !operand2.include?(operand1) ? true : false
        elsif operator.is_a?(Hash)
            regex      = operator['regex']
            is_negated = operator['is_regex_negated']
            result     = regex.match(operand1) ? true : false
            result = is_negated ? !result : result
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
        logical_operators  = %w[and or]
        sql_list_operators = %w[in not\ in]
        objects.each do |object|
            completed_expression = []
            expressions.each do |exp|
                # Lookup operators => and or
                if logical_operators.include?(exp)
                    completed_expression << boolean_operator_lookup[exp]
                    next
                end
                preceding_parentheses = exp[0]
                # Capture method to be called on object
                method_name = exp[1]
                # Self explanatory
                comparison_operator = exp[2]
                # Capture value to be compared against method call's return value
                value = exp[3]
                trailing_parentheses = exp[4]
                # Capture method call return value
                obj_attr_data = object.send(method_name.to_sym)
                # Addresses comparison mismatch between Strings and Integers
                if sql_list_operators.include?(comparison_operator)
                    obj_attr_data = obj_attr_data.to_s
                end
                # Evaluate expression
                result = evaluate(obj_attr_data,comparison_operator,value)
                # Format expressions
                exp_str = "#{preceding_parentheses}#{result}#{trailing_parentheses}"
                completed_expression << exp_str
            end
            # Convert independent expressions to one string => e.g "(true && false) || true"
            completed_expression = completed_expression.join(' ')
            # p completed_expression
            # Grab object if it meets search criteria
            # SECURITY: This is what a completed_expression
            # would look like BEFORE being passed to eval: "(true && false) || true" => true
            result = eval(completed_expression)
            matches << object if result == true
        end
        matches
    end
    alias find_match find_matches
end
