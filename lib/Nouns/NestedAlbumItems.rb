require_relative '../JsonBuilder'
require_relative 'NestedItemBasic'
class NestedAlbumItems < NestedItemBasic
    #attr_accessor :id
    # Creates a NestedAlbumItems object
    #
    # @param data [Integer, String, nil] Takes an Integer, String, or no argument
    # @return [NestedAlbumItems object]
    #
    # @example
    #          nstd_albums_item = NestedAlbumItems.new => Empty obj
    #          nstd_albums_item = NestedAlbumItems.new("17")
    #          nstd_albums_item = NestedAlbumItems.new(17)
    def initialize(data=nil)
        super(data)
    end
end