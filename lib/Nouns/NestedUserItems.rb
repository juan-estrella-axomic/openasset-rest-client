# NestedUserItems class
#
# @author Juan Estrella
require_relative 'NestedItemBasic'
class NestedUserItems < NestedItemBasic
    # @!parse attr_accessor :id, :can_modify

    # Creates a NestedUserItems object
    #
    # @param data [Integer, String, nil] Takes an Integer, String, or no argument
    # @return [NestedUserItems object]
    #
    # @example
    #          nstd_user_item = NestedUserItems.new => Empty obj
    #          nstd_user_item = NestedUserItems.new("17")
    #          nstd_user_item = NestedUsertems.new(17)
    def initialize(arg1=nil,arg2=nil)
        super(arg1,arg2)
    end
end