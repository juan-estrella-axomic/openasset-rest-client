require_relative '../JsonBuilder'
class NestedFieldItems
    include JsonBuilder
    # @!parse attr_accessor :id, :values
    attr_accessor :id, :values

    # Creates an NestedFieldItems object
    #
    # @param arg1 [Hash, Integer, String, nil] Takes a Hash, Integer, String argument or nil
    # @param arg2 [Integer, String, Array] Takes an Array, Integer, or String argument
    # @return [NestedFieldItems object]
    #
    # @example
    #          nstd_fld_item = NestedFieldItems.new => Empty obj
    #          nstd_fld_item = NestedFieldItems.new({:id => 14, :values => ["data"]})
    #          nstd_fld_item = NestedFieldItems.new("14","data")
    #          nstd_fld_item = NestedFieldItems.new("14",["data"])
    def initialize(arg1=nil,arg2=nil)

        json_obj = nil
        if arg1.is_a?(Hash) || arg1.nil?
            json_obj = Validator::validate_argument(arg1,'NestedFieldItems')
        elsif (arg1.is_a?(Integer) || arg1.is_a?(String)) &&
              (arg2.is_a?(Integer) || arg2.is_a?(String))
              json_obj = {:id => arg1.to_s, :values => [arg2.to_s]}
        elsif (arg1.is_a?(Integer) || arg1.is_a?(String)) &&
              (arg2.is_a?(Integer) || arg2.is_a?(String) || arg2.is_a?(Array))

            arg2 = [arg2.to_s]      unless arg2.is_a?(Array)
            json_obj = {:id => arg1.to_s, :values => arg2}

        else # Its probably an Array or something else. the Validator will display error and abort
            Validator::validate_argument(arg1,'NestedFieldItems')
        end

        @id     = json_obj[:id]
        @values = json_obj[:values]
    end
end