module JsonBuilder
    def json
        json_obj = Hash.new
        self.instance_variables.each do |var|
            var = var.to_s.gsub(':','')
            value = self.instance_variable_get(var)
            next if value.nil?
            key = var.gsub('@','').to_sym
            if value.is_a?(String) || value.is_a?(Integer) || values.is_a?(Float)
                json_obj[key] = value
            elsif value.is_a?(Array)
                if value.first.respond_to?(:json)
                    json_obj[key] = value.map { |obj| obj.json }
                else
                    json_obj[key] = value
                end
            else # Value is an object so recurse
                json_obj[key] = value.json
            end
        end
        json_obj
    end
end