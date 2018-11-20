
module CustomObjectBuilder
    private
    def __populate_object_fields(options)
        options.each do |values|
            method_name, item = nil

            if values.length > 1 # It's a key value pair
                method_name = values.first.to_s
                item        = values[1] # this can be an array or object
            else # It's a json object
                item = values.first
            end

            case item.class.to_s
            when 'Array'
                # Process each element in json recursively
                tmp = []
                item.each do |element|
                    # NestedGenericObject class contains a recursive constructor
                    tmp << NestedGenericObject.new(element)
                end
                send("#{method_name}=", tmp)
            when 'Hash'
                send("#{method_name}=", NestedGenericObject.new(item))
            else
                send("#{method_name}=", item)
            end
        end
    end
end
