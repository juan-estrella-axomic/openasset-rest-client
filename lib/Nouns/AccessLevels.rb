# AccessLevels class
#
# @author Juan Estrella
require_relative '../JsonBuilder'
class AccessLevels
    include JsonBuilder
    # @!parse attr_accessor :id, :label
    attr_accessor :id, :label

    # Creates an AccessLevels object
    #
    # @param data [Hash, nil] Takes a JSON object/Hash or no argument
    # @return [AccessLevels object]
    #
    # @example
    #         access_level = AccessLevels.new
    def initialize(data=nil)
        json_obj = Validator.validate_argument(data,'AccessLevels')
        @id      = json_obj['id']
        @label   = json_obj['label']
    end
end