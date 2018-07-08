# Generic nested object id class => For nested users and groups
#
# @author Juan Estrella
require_relative '../JsonBuilder'
class NestedItemBasic
    include JsonBuilder

    attr_accessor :id

    def initialize(arg1=nil,arg2=nil)
        json_obj = {}
        if !arg2 && arg1.to_i > 0# When only the id is needed. Happens when nested inside Users object
            json_obj['id'] = arg1       
        elsif arg1 && arg2                 # When can_modify(arg1) AND id(arg2) is needed. 
            json_obj['can_modify'] = arg1  # Happens when nested inside Albums or Searches object 
            json_obj['id']         = arg2    
        else
            # arg1 can also be hash or nil
            json_obj = Validator.validate_argument(arg1,'Nested Group/User')
        end

        # Always set the id attribute
        @id = json_obj['id']
        if arg2
            @can_modify = arg2 # Create and set can_modify attribute if needed
            # Dynamically add getter and setter methods for can_modify attribute
            self.define_singleton_method('can_modify=') do |val|
                @can_modify = val
            end
            self.define_singleton_method('can_modify') do
                @can_modify
            end
        end
    end
end