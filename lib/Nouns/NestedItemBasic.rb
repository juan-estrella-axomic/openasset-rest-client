# Generic nested object id class => For nested users and groups
#
# @author Juan Estrella
require_relative '../JsonBuilder'
class NestedItemBasic
    include JsonBuilder

    attr_accessor :id

    def initialize(arg1=nil,arg2=nil,type='')
        json_obj = {}
        if /field/i.match(type) # When id(arg1) AND values(arg2) is used. => NestedFieldItems
            arg2 = arg2.is_a?(Array) ? arg2 : [arg2]
            json_obj['id'] = arg1
            json_obj['values'] = arg2
        elsif !arg2 && arg1.respond_to?(:to_i) && arg1.to_i > 0# When only the id is used. Happens when object is nested inside Users object
            json_obj['id'] = arg1
        elsif arg1 && arg2                 # When can_modify(arg1) AND id(arg2) are used. Happens when object is nested inside Albums or Searches object
            json_obj['can_modify'] = arg1
            json_obj['id']         = arg2
        else
            # arg1 can also be hash or nil
            json_obj = Validator.validate_argument(arg1,"#{type}",'String, Integer')
        end

        # Always set the id attribute
        @id = json_obj['id']

        # Create and set second attributes if needed
        second_variable_name = nil
        if /field/i.match(type)
            second_variable_name = 'values'
        end

        if arg2 && !/field/i.match(type)
            second_variable_name = 'can_modify'
        end

        if second_variable_name
            instance_variable_set("@#{second_variable_name}",
                                  json_obj[second_variable_name])
        end
    end
end