require_relative '../JsonBuilder'
require_relative 'NestedItemBasic'
require_relative '../Validator'
class NestedFieldItems < NestedItemBasic
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
        type = self.class.to_s
        if !arg1.is_a?(Hash)
            if !arg2
                Validator.validate_argument(arg1,type,'two arguments(id,string data)')
            end
        end
        super(arg1,arg2,type)
    end
end