require_relative '../JsonBuilder'
require_relative 'NestedItemBasic'
class NestedAlbumItems < NestedItemBasic
    # Creates a NestedAlbumItems object
    #
    # @param data [Integer, String, nil] Takes an Integer, String, or no argument
    # @return [NestedAlbumItems object]
    #
    # @example
    #          nstd_albums_item = NestedAlbumItems.new => Empty obj
    #          nstd_albums_item = NestedAlbumItems.new("17")
    #          nstd_albums_item = NestedAlbumItems.new(17)
    def initialize(arg1=nil)
        super(arg1)
    end
end