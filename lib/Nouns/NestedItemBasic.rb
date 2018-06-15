# Generic nested object id class => For nested users and groups
# 
# @author Juan Estrella
class NestedItemBasic
    attr_accessor :id

    def initialize(val)
        json_obj = {}

        if val.to_i > 0 # Check if a non-zero numeric value is passed
            json_obj['id'] = val
        else                        # Assume a Hash or nil was passed
            json_obj = Validator::validate_argument(args.first,'Nested Group/User')
        end

        @id = json_obj['id']
    end

    # @!visibility private
    def json
        json_data = Hash.new
        json_data[:id] = @id            unless @id.nil?

        return json_data        
    end
end