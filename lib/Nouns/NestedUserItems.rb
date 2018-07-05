# NestedUserItems class
#
# @author Juan Estrella
require_relative 'NestedItemBasic'
class NestedUserItems < NestedItemBasic
    def initialize(*args)
        if args.length == 1 # Id only objects => subnoun to a group
            super(args.first)
        else args.length > 1 # objects that have id and can_modify => subnoun to album
            super(args[1])
            @can_modify = args.first
            self.define_singleton_method('can_modify=') do |val|
                @can_modify = val
            end
            self.define_singleton_method('can_modify') do
                @can_modify
            end
        end
    end
end