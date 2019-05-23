module ObjectGenerator
	# @!visibility private
    def generate_objects_from_json_response_body(json,resource_type)

        unless json.empty?

            # Dynamically infer the the class needed to create objects by using the request_uri REST endpoint
            # returns the Class constant so we can dynamically set it below
            inferred_class = Object.const_get(resource_type)

            # Create array of JSON Converted to objects => this can include Nouns AND Error objects
            objects_array = json.map do |item|
                obj = nil
                if item.has_key?("error_message")
                    obj = Error.new(item["existing_id"],
                                    item["resource_name"],
                                    item["resource_type"],
                                    item["http_status_code"],
                                    item["error_message"])

                else
                    obj = inferred_class.new(item)
                end
                obj
            end
            # return array of rest noun and/or error objects
            return objects_array
        else
            # return empty body
             return json
        end
    end

end