# EmployeeKeywords class
#
# @author Juan Estrella
require_relative '../JsonBuilder'
class EmployeeKeywords
    include JsonBuilder
    # @!parse attr_accessor 'name', 'employee_keyword_category_id', 'employee_count', 'id'
    attr_accessor 'name', 'employee_keyword_category_id', 'employee_count', 'id'

    # Creates a EmployeeKeywords object
    #
    # @param data [Hash, nil] Takes a JSON object/Hash or no argument
    # @return [EmployeeKeywords object]
    #
    # @example
    #         employee_keyword = EmployeeKeywords.new('test','1')
    def initialize(name,employee_keyword_category_id=nil)
        data = nil
        if name.is_a?(Hash)
            data = name
        else
            data = {
                'name'                         => name,
                'employee_keyword_category_id' => employee_keyword_category_id
            }
        end
        json_obj = Validator.validate_argument(data,'EmployeeKeywords')
        @id                           = json_obj['id']
        @name                         = json_obj['name']
        @employee_count               = json_obj['employee_count']
        @employee_keyword_category_id = json_obj['employee_keyword_category_id']
    end
end
