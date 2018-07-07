# CopyrightHolders class
#
# @author Juan Estrella
require_relative '../JsonBuilder'
class CopyrightHolders
    include JsonBuilder
    # @!parse attr_accessor :copyright_policy_id, :id, :name
    attr_accessor :copyright_policy_id, :id, :name

    # Creates a CopyrightHolders object
    #
    # @param data [Hash, nil] Takes a JSON object/Hash or no argument
    # @return [CopyrightHolders object]
    #
    # @example
    #         copyright_holder = CopyrightHolders.new
    def initialize(data=nil)
        json_obj = Validator::validate_argument(data,'CopyrightHolders') unless data.is_a?(String)
        json_obj = {"name" => data}                                      if data.is_a?(String)
        @copyright_policy_id = json_obj['copyright_policy_id']
        @id = json_obj['id']
        @name = json_obj['name']
    end
end