module ErrorHandler
	# @!visibility private
    def process_errors(data=nil,res=nil,resource=nil,operation='')

        return unless data && res && resource

        json_obj_collection = Array.new
        errors              = Array.new
        json_body           = Array.new
        
        name = (resource == 'Files') ? '@filename' : '@name'

        begin
            jsonBody = JSON.parse(res.body) if res.body
        rescue JSON::ParserError => err
            logger.error("JSON Parser Error: #{err.message}")
        end

        if !jsonBody.is_a?(Array)
            jsonBody = [jsonBody]
        end
        
        data = [data] unless data.is_a?(Array)

        if res.body
            jsonBody.each_with_index do |obj,index|
                if obj.is_a?(Hash) && obj.has_key?("error_message")

                    err = Hash.new

                    if data[index].is_a?(Files)
                        err['id'] = data[index].id || 'n/a'
                        err['resource_name'] = data[index].instance_variable_get(name) || 'n/a'
                    elsif data[index].is_a?(Hash)
                        key = name.gsub('@','')
                        err['id'] = data[index]['id'] || 'n/a'
                        err['resource_name'] = data[index][key] || 'n/a'
                    end

                    err['resource_name']    = data[index].instance_variable_get(name)
                    err['resource_type']    = resource  # Determined by api endpoint
                    err['http_status_code'] = obj['http_status_code']
                    err['error_message']    = obj['error_message']
    
                    errors << err
                    json_obj_collection << err
                else
                    json_obj_collection << obj
                end
            end
        end

        unless errors.empty?
            errors.each do |e|
                n = e["resource_name"]
                r = e["resource_type"]
                i = e["id"]
                m = e["error_message"]
                c = e["http_status_code"]
                logger.error("#{operation} failed for #{r.inspect} object: #{n}")
                logger.error("#{r.chop} id: #{i}")   unless i.nil?
                logger.error("Message: #{m}")
                logger.error("HTTP Status Code: #{c}")
            end
        end

        json_obj_collection 
    end
end