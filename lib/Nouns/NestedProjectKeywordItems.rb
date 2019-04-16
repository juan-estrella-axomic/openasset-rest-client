require_relative '../JsonBuilder'
require_relative 'NestedItemBasic'
class NestedProjectKeywordItems < NestedItemBasic
    include JsonBuilder
    # @!parse attr_accessor :id
    #attr_accessor :id

    # Creates a NestedProjectKeywordItems object
    #
    # @param data [Integer, String, nil] Takes an Integer, String, or no argument
    # @return [NestedProjectKeywordItems object]
    #
    # @example
    #          nstd_proj_kwd_item = NestedProjectKeywordItems.new => Empty obj
    #          nstd_proj_kwd_item = NestedProjectKeywordItems.new("17")
    #          nstd_proj_kwd_item = NestedProjectKeywordItems.new(17)
    def initialize(data=nil)
        super(data)
    end
end