module JsonBuilder
    def json
        json_obj = Hash.new
        self.instance_variables.each do |var|
            var = var.to_s.gsub(':','')
            value = self.instance_variable_get(var)
            next if value.nil?
            key = var.gsub('@','').to_sym
            if value.is_a?(String)
                json_obj[key] = value
            elsif value.is_a?(Array) && !value.empty?
                json_obj[key] = value.map { |obj| obj.json }
            end
        end
        json_obj
    end
end