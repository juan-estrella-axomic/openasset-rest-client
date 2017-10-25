class NestedProjectKeywordItems
    
    attr_accessor :id

    def initialize(data=nil)
        json_obj = nil
        #check for an integer or string that can be converted to an integer
        unless (data.is_a?(Integer) || data.is_a?(String)) && data.to_i != 0 
            json_obj = Validator::validate_argument(data,'NestedProjectKeywordItems')
            @id = json_obj['id']
        else
            @id = data
        end     
    end

    def json
        json_data = Hash.new
        json_data[:id] = @id    unless @id.nil?
        
        return json_data
    end
    
end