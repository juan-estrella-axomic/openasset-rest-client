# AlternateStores
#
# @author Juan Estrella
require_relative '../JsonBuilder'
class AlternateStores
    include JsonBuilder
    # @!parse attr_accessor :id, :name, :storage_name
    attr_accessor :id, :name, :storage_name

    # Creates an AlternateStores object
    #
    # @param data [Hash, nil] Takes a JSON object/Hash or no argument
    # @return [AlternateStores object]
    #
    # @example
    #         alternate_store = AlternateStores.new
    def initialize(data=nil)
        json_obj = Validator::validate_argument(data,'AlternateStores')
        @id = json_obj['id']
        @name = json_obj['name']
        @storage_name = json_obj['storage_name']
    end
end