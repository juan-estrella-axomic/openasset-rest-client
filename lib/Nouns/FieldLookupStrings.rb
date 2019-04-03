# FieldLookupStrings class
#
# @author Juan Estrella
require_relative '../JsonBuilder'
class FieldLookupStrings
    include JsonBuilder
    # @!parse attr_accessor :id, :display_order, :value
    attr_accessor :id, :display_order, :value

    # Creates a FieldLookupStrings object
    #
    # @param data [Hash, nil] Takes a JSON object/Hash or no argument
    # @return [FieldLookupStrings object]
    #
    # @example
    #         fls_object = FieldLookupStrings.new
    def initialize(data=nil)
        json_obj       = {"value" => data} if data.is_a?(String)
        json_obj       = Validator.validate_argument(data,"FieldLookupStrings") unless data.is_a?(String)
        @id            = json_obj['id']
        @display_order = json_obj['display_order']
        @value         = json_obj['value']
    end
end
