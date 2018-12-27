require 'net/http'

MAX_REQUEST_RETRIES = 7

RECOVERABLE_NET_HTTP_EXCEPTIONS = [
    Net::HTTPBadGateway,
    Net::HTTPServiceUnavailable
]
