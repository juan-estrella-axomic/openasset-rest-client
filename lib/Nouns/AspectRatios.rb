# AspectRatios class
#
# @author Juan Estrella
require_relative '../JsonBuilder'
require_relative '../Validator'
class AspectRatios
    include JsonBuilder
    # @!parse attr_accessor :id, :code, :label
    attr_accessor :id, :code, :label

    # Creates an AspectRatios object
    #
    # @param data [Hash, nil] Takes a JSON object/Hash or no argument
    # @return [AspectRatios object]
    #
    # @example
    #         aspect_ratio = AspectRatios.new
    def initialize(data=nil)
        json_obj = Validator::validate_argument(data,'AspectRatios')
        @id = json_obj['id']
        @code = json_obj['code']
        @label = json_obj['label']
    end
end