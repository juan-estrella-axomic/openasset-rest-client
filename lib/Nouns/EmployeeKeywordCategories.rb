# EmployeeKeywordCategories class
#
# @author Juan Estrella
require_relative '../JsonBuilder'
class EmployeeKeywordCategories
    include JsonBuilder
    # @!parse attr_accessor :id, :code, :name, :display_order
    attr_accessor :id, :code, :name, :display_order

    # Creates a EmployeeKeywordCategories object
    #
    # @param data [Hash, nil] Takes a JSON object/Hash or no argument
    # @return [EmployeeKeywordCategories object]
    #
    # @example
    #         employee_keyword_category = EmployeeKeywordCategories.new
    def initialize(data=nil)
        json_obj = {'name' => data} if data.is_a?(String)
        json_obj = Validator.validate_argument(data,'EmployeeKeywordCategories') unless data.is_a?(String)
        @id            = json_obj['id']
        @code          = json_obj['code']
        @name          = json_obj['name']
        @display_order = json_obj['display_order']
    end
end
