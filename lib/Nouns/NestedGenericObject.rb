# This is a special blank canvas object 
# used as nested objects in custom objects
require_relative '../Generic.rb'
require_relative '../JsonBuilder.rb'
require_relative '../CustomObjectBuilder.rb'

class NestedGenericObject < Generic
    include JsonBuilder
    include CustomObjectBuilder
    def initialize(options = {})
        __populate_object_fields(options)
    end
end