require 'net/http'

MAX_REQUEST_RETRIES = 5

RECOVERABLE_NET_HTTP_EXCEPTIONS = [
    Net::HTTPBadGateway,
    Net::HTTPServiceUnavailable
]

COMPARISON_OPERATORS = %w[
    >=
    <=
    >
    <
    !
]