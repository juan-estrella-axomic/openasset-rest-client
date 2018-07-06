# AccessLevels class
#
# @author Juan Estrella
require_relative '../Validator'
class AccessLevels

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

    # @!visibility private
    def json
        json_data = Hash.new
        json_data[:id]    = @id     unless @id.nil?
        json_data[:label] = @label  unless @label.nil?

        return json_data
    end
end