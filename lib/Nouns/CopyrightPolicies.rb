# CopyrightPolicies class
# 
# @author Juan Estrella
class CopyrightPolicies

    # @!parse attr_accessor :code, :description, :id, :name
    attr_accessor :code, :description, :id, :name

    # Creates an CopyrightPolicies object
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

    # @!visibility private
    def json
        json_data = Hash.new
        json_data[:code] = @code                unless @code.nil?
        json_data[:description] = @description  unless @description.nil?
        json_data[:id] = @id                    unless @id.nil?
        json_data[:name] = @name                unless @name.nil?

        return json_data
    end

end