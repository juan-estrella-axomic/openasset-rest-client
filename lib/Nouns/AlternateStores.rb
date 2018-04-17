# AlternateStores
# 
# @author Juan Estrella

class AlternateStores

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

    # @!visibility private
    def json
        json_data = Hash.new
        json_data[:id] = @id                      unless @id.nil?
        json_data[:name] = @name                  unless @name.nil?
        json_data[:storage_name] = @storage_name  unless @storage_name.nil?

        return json_data
    end

end