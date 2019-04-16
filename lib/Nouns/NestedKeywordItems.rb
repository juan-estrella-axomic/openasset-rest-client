require_relative '../JsonBuilder'
require_relative 'NestedItemBasic'
class NestedKeywordItems < NestedItemBasic
    include JsonBuilder
    # @!parse attr_accessor :id
    #attr_accessor :id

    # Creates a NestedKeywordItems object
    #
    # @param data [Integer, String, nil] Takes an Integer, String, or no argument
    # @return [NestedKeywordItems object]
    #
    # @example
    #          nstd_kwd_item = NestedKeywordItems.new => Empty obj
    #          nstd_kwd_item = NestedKeywordItems.new("17")
    #          nstd_kwd_item = NestedKeywordItems.new(17)
    def initialize(data=nil)
        super(data)
    end
end