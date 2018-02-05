class NestedKeywordItems

    # @!parse attr_accessor :id
    attr_accessor :id

    # Creates a NestedKeywordItems object
    #
    # @param data [Integer, String, nil] Takes an Integer, String, or no argument
    # @return [NestedKeywordItems object]
    #
    # @example 
    #          nstd_kwd_item = NestedKeywordItems.new => Empty obj
    #          nstd_kwd_item = NestedKeywordItems.new("17")
    #          nstd_kwd_item = NestedKeywordItems.new(17)
    def initialize(data=nil)
        json_obj = nil
        #check for an integer or string that can be converted to an integer
        unless (data.is_a?(Integer) || data.is_a?(String)) && data.to_i != 0 
            json_obj = Validator::validate_argument(data,'NestedKeywordItems')
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