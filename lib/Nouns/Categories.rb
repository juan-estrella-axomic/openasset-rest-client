#Categories class
#
# @author Juan Estrella
require_relative '../JsonBuilder'
require_relative '../Validator'
class Categories
    include JsonBuilder
    # @!parse attr_accessor :alive, :code, :default_access_level, :default_rank, :description, :display_order
    attr_accessor :alive, :code, :default_access_level, :default_rank, :description, :display_order

    # @!parse attr_accessor :alive, :code, :default_access_level, :default_rank, :description, :display_order
    attr_accessor :id, :name, :projects_category

    # Creates a Categories object
    #
    # @param data [Hash, nil] Takes a JSON object/Hash or no argument
    # @return [Categories object]
    #
    # @example
    #         category = Categories.new
    def initialize(data=nil)
        json_obj = Validator::validate_argument(data,'Categories')
        @alive = json_obj['alive']
        @code = json_obj['code']
        @default_access_level = json_obj['default_access_level']
        @default_rank = json_obj['default_rank']
        @description = json_obj['description']
        @display_order = json_obj['display_order']
        @id = json_obj['id']
        @name = json_obj['name']
        @projects_category = json_obj['projects_category']
    end
end