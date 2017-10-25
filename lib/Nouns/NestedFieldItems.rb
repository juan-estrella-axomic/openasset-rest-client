class NestedFieldItems
    
    attr_accessor :id, :values

    def initialize(arg1=nil,arg2=nil)

        json_obj = nil
        if arg1.is_a?(Hash) || arg1.nil?
            json_obj = Validator::validate_argument(arg1,'NestedFieldItems')
        elsif (arg1.is_a?(Integer) || arg1.is_a?(String)) &&
              (arg2.is_a?(Integer) || arg2.is_a?(String))
              json_obj = {:id => arg1.to_s, :values => [arg2.to_s]}
        elsif (arg1.is_a?(Integer) || arg1.is_a?(String)) &&
              (arg2.is_a?(Integer) || arg2.is_a?(String) || arg2.is_a?(Array)) 

            arg2 = [arg2.to_s]      unless arg2.is_a?(Array)
            json_obj = {:id => arg1.to_s, :values => arg2}

        else # Its probably an Array or something else. the Validator will display error and abort
            Validator::validate_argument(arg1,'NestedFieldItems')
        end
        
        @id     = json_obj[:id]
        @values = json_obj[:values]
    end

    def json
        json_data = Hash.new
        json_data[:id]     = @id       unless @id.nil?
        json_data[:values] = @values   unless @values.empty?
        return json_data
    end
    
end