#Categories class
# 
# @author Juan Estrella
class Categories

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

    # @!visibility private
    def json
        json_data = Hash.new
        json_data[:alive] = @alive                                  unless @alive.nil?
        json_data[:code] = @code                                    unless @code.nil?
        json_data[:default_access_level] = @default_access_level    unless @default_access_level.nil?
        json_data[:default_rank] = @default_rank                    unless @default_rank.nil?
        json_data[:description] = @description                      unless @description.nil?
        json_data[:display_order] = @display_order                  unless @display_order.nil?
        json_data[:id] = @id                                        unless @id.nil?
        json_data[:name] = @name                                    unless @name.nil?
        json_data[:projects_category] = @projects_category          unless @projects_category.nil?
    
        return json_data
    end

end