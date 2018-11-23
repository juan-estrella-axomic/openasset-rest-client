
module CustomObjectBuilder
    private
    def __populate_object_fields(options)
        options.each do |key, value|

            method_name = key.to_s
            value ||= key # When options is the rows of a grid

            case value.class.to_s
            when 'Array'
                # Process each element in json recursively
                tmp = []
                value.each do |element|
                    # NestedGenericObject class contains a recursive constructor
                    tmp << GridRow.new(element)
                end
                send("#{method_name}=", tmp)
            when 'Hash'
                send("#{method_name}=", Grid.new(value))
            else
                send("#{method_name}=", value)
            end
        end
    end
end
