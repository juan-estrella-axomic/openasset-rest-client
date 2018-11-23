
module CustomObjectBuilder
    private
    def __populate_object_fields(options)
        options.each do |method_name, value|
            case value.class.name
            when 'Array'
                rows = value.map { |item| GridRow.new(item) }
                send("#{method_name}=", rows)
            when 'Hash'
                send("#{method_name}=", Grid.new(value))
            else
                send("#{method_name}=", value)
            end
        end
    end
end
