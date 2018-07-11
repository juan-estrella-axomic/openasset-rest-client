require_relative '../JsonBuilder'
class SearchItems
    include JsonBuilder
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
    def initialize(data)
        json_obj = Validator.validate_argument(data,'Search Items')

        @code
        @exlcude
        @operator
        @values
        @ids

        json_obj.keys.each do |key|
            value = json_obj[key]
            key = key.to_s # In case symbols are used instead of strings
            instance_variable_set("@#{key}",value)
        end
    end
end