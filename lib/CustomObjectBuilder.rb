
module CustomObjectBuilder
    # Converts arbitrarily nested json into custom object.
    #
    # @param options [Hash] JSON object
    # @return [CustomObject] the json object converted into Custom object.
        private
    def __populate_object_fields(options)
        options.each do |method_name, value|
            case value
            when Array
                rows = value.map { |item| GridRow.new(item) }
                send("#{method_name}=", rows)
            when Hash
                send("#{method_name}=", Grid.new(value))
            else
                send("#{method_name}=", value)
            end
        end
    end
end
