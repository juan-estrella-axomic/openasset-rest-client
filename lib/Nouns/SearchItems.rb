class SearchItems

    # @!parse attr_accessor :code, :exclude, :operator, :values
    attr_accessor :code, :exclude, :operator, :values

    # Creates a SearchItems object
    #
    # @param args [ String, bool or nil] Default => nil
    # @return [SearchItems object]
    #
    # @example
    #         search =  SearchItems.new
    #         search =  SearchItems.new('albums','0','>','34') => Files in albums with id greater than 34
    def initialize(*args)
        json_obj = nil
        if args.first.is_a?(Hash)
            json_obj = Validator::validate_argument(args.first,'SearchItems')
        elsif args.empty?
            json_obj = Validator::validate_argument(args.first, 'SearchItems')
        elsif (args.length == 4  &&
            args[0].is_a?(String) &&
            (args[1] == 1 || args[1] == 0 || args[1] == '1' || args[1] == '0') &&
            (args[2] == '-' || args[2] == '+' || args[2] == '' || args[2] == nil) &&
             args[3].is_a?(Array))

            json_obj = {}
            json_obj['code']       = args[0]
            json_obj['exclude']    = args[1]
            json_obj['operator']   = args[2]
            json_obj['values/ids'] = args[3]
        else
            puts "Argument Error:\n\tInvalid argument detected for nested search items object." +
                 "Expected a Hash, Nil, or 4 arguments in constructor.\n\tReceived => #{args.inspect}"
            return false
        end

        @code     = json_obj['code']
        @exlcude  = json_obj['exclude']
        @operator = json_obj['operator']
        @values   = json_obj['values/ids'] || Array.new
    end

    def json
        json_data = Hash.new
        json_data[:code]        = @code        unless @code.nil?
        json_data[:exclude]     = @exclude     unless @exclude.nil?
        json_data[:operator]    = @operator    unless @operator.nil?
        json_data['values/ids'] = @values

        return json_data
    end

end