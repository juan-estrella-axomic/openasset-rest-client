require_relative '../JsonBuilder'
class NestedAlbumItems
    include JsonBuilder
    # @!parse attr_accessor :id
    attr_accessor :id

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
        json_obj = nil
        #check for an integer or string that can be converted to an integer
        unless (data.is_a?(Integer) || data.is_a?(String)) && data.to_i != 0
            json_obj = Validator::validate_argument(data,'NestedAlbumItems')
            @id = json_obj['id']
        else
            @id = data
        end
    end
end