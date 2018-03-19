require 'json'

module MyEncoder

    def encode_json_to_utf8(json_body,enc_out,enc_in)

        enc_in           = enc_in.downcase
        enc_out          = enc_out.downcase
        unprocessed_json = json_body # <= Actual JSON object - (NOT A JSON String)
        enc_json_str     = nil

        
        begin
            enc_json_str = unprocessed_json.to_json.encode(enc_out, 
                                                           enc_in, 
                                                           invalid: :replace, 
                                                           undef: :replace, 
                                                           replace: '?')
        rescue JSON::ParserError => json_err
            unprocessed_json.each do |key,val|
                if unprocessed_json[key].is_a?(Array) ## It's a nested field
                    unprocessed_json[key].each do |nested_key,nested_value| 
                        if nested_value.is_a?(Array) # It's a field value
                            unprocessed_json[key][nested_key].each do |text| 
                                text.to_s.encode!(enc_out, 
                                                  enc_in, 
                                                  invalid: :replace, 
                                                  undef: :replace, 
                                                  replace: '?')
                            end
                        else # Just a regular json key value pair
                            unprocessed_json[key][nested_key].to_s.encode!(enc_out, 
                                                                           enc_in, 
                                                                           invalid: :replace, 
                                                                           undef: :replace, 
                                                                           replace: '?')
                        end
                    end
                else # Not a nested field
                    unprocessed_json[key].to_s.encode!(enc_out, 
                                                       enc_in, 
                                                       invalid: :replace, 
                                                       undef: :replace, 
                                                       replace: '?')
                end 
            end
            enc_json_str = unprocessed_json.to_json
        rescue Exception => e
            logger.error(e.message)
        end
        
        enc_json_str.scrub!('?') # Replaces invalid byte sequence with '?'
    end
      
end