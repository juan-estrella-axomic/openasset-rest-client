require 'net/http'

module Custom
    module HTTPMethod
        class Merge < Net::HTTPRequest
            METHOD            = 'MERGE'
            REQUEST_HAS_BODY  = true
            RESPONSE_HAS_BODY = true
        end
    end
end
