require_relative '../Generic'
require_relative '../JsonBuilder'
require_relative '../CustomObjectBuilder.rb'
require_relative '../MyLogger.rb'

class CustomObject < Generic
    include JsonBuilder
    include CustomObjectBuilder
    include Logging

    attr_accessor :id, :code, :descriptor, :updated

    def initialize(options = {})
        @id         = nil
        @code       = nil
        @descriptor = nil
        @updated    = nil
        unless options.is_a?(Hash)
            logger.warn('Expected hash as argument. '\
                        "Creating empty #{self.class} object")
            return
        end
        __populate_object_fields(options)
    end
end
