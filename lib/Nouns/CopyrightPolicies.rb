# CopyrightPolicies class
#
# @author Juan Estrella
require_relative '../JsonBuilder'
class CopyrightPolicies
    include JsonBuilder
    # @!parse attr_accessor :code, :description, :id, :name
    attr_accessor :code, :description, :id, :name

    # Creates a CopyrightPolicies object
    #
    # @param data [Hash, nil] Takes a JSON object/Hash or no argument
    # @return [CopyrightPolicies object]
    #
    # @example
    #         cp_policy = CopyrightPolicies.new
    def initialize(data=nil)
        json_obj = Validator::validate_argument(data,'CopyrightPolicies') unless data.is_a?(String)
        json_obj = {"name" => data}                                       if data.is_a?(String)
        @code = json_obj['code']
        @description = json_obj['description']
        @id = json_obj['id']
        @name = json_obj['name']
    end
end