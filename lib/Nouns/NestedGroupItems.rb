# NestedGroupItems class
#
# @author Juan Estrella
require_relative 'NestedItemBasic'
class NestedGroupItems < NestedItemBasic
    # @!parse attr_accessor :id, :can_modify

    # Creates a NestedGroupItems object
    #
    # @param data [Integer, String, nil] Takes an Integer, String, or no argument
    # @return [NestedGroupItems object]
    #
    # @example
    #          nstd_group_item = NestedGroupItems.new => Empty obj
    #          nstd_group_item = NestedGroupItems.new("17")
    #          nstd_group_item = NestedGroupItems.new(17)
    def initialize(arg1=nil,arg2=nil)
        super(arg1,arg2)
    end
end