require_relative 'MyLogger'
require_relative 'RestOptions'

class HTTPQueryBuilder

    include Logging

    def initialize
        @options = RestOptions.new
        @precise_search = true
    end

    def build_query(expressions)
        return unless expressions.is_a?(Array)
        # Strip out parethesis since they are not used in http query strings
        while exp = expressions.shift
            # skip "and/or" since everything is anded together for api calls
            if exp.eql?('or')
                logger.error('OR operator not supported for query strings')
                abort
            end
            # toss any leading parenthesis
            exp.shift
            # toss any trailing parenthesis
            exp.pop
            # grab field
            field = exp.shift
            # grab operator
            operator = exp.shift
            # grab search data
            search_data = exp.shift
            # create search expression used by api => "=>=917"
            search_criteria = translate_search_data_format(operator,search_data)
            # Add search term to query string
            @options.add_option(field,search_criteria) # "?/& id=>=917"
        end
        # Set text precision
        precision = @precise_search ? 'exact' : 'contains'
        @options.add_option('textMatching',precision)
        @options
    end

    private

    def translate_search_data_format(operator,search_data)
        negation_prefix     = ''
        comparison_operator = '='
        data                = ''
        if operator.is_a?(Hash) # It's a "like" or "not like" sql statement
            negation_prefix = ''
            negation_prefix = '!' if operator['is_regex_negated']
            @precise_search = false if search_data.include?('%')
        elsif operator.eql?('between') # It's a range  =9-17
            data = search_data.join('-')
        else # It's a regular old comparison operator
            op = operator
        end
        return negation_prefix + comparison_operator + data
    end
end