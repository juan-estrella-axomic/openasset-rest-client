require_relative 'MyLogger'
require_relative 'RestOptions'

class HTTPQueryBuilder

    include Logging

    def initialize
        @op = RestOptions.new
        @precise_search
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
            # grab the comparison operator
            operator = exp.shift
            # grab search data
            search_data = exp.shift
            # create search expression used by api => "=>=917"
            search_criteria = translate_search_data_format(operator,search_data)
            search_term = field + search_criteria
            # Add search term to query string
            @op.add_raw_option(search_term) # "?/& id=>=917"
        end
        # Set text search precision if a Boolean value is set
        unless @precise_search.nil?
            precision = @precise_search ? 'exact' : 'contains'
            @op.add_option('textMatching',precision)
        end
        @op.add_option('limit',0)
        @op
    end

    private

    def translate_search_data_format(operator,search_data)
        negation_prefix     = ''
        comparison_operator = '='
        data                = search_data
        if operator.is_a?(Hash) # It's a "like" or "not like" sql statement
            negation_prefix = ''
            negation_prefix = '!' if operator['is_regex_negated']
            @precise_search = search_data.include?('%') ? false : true # context for setting texMatching parameter value
            search_data.to_s.gsub!('%','') # Remove % since it's not an actual part of the value we are searching
        elsif operator.eql?('between') # It's a range  =9-17
            start_value = search_data.first
            end_value   = search_data.last
            search_data = start_value + '-' + end_value
            #data = [*start_value..end_value].join(',')
        else# It's a regular old comparison operator
            # '=' is converted to '==' in the SQL parser
            # This prevents field===value from being set in query string
            comparison_operator += operator unless operator.eql?('==')
        end
        return comparison_operator + negation_prefix + search_data.to_s
    end
end
