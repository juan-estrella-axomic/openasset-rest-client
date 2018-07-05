# NestedFileItems class
#
# @author Juan Estrella
require_relative 'NestedItemBasic'
class NestedFileItems < NestedItemBasic
    def initialize(*args)
        if args.length == 1
            super(args.first)
        else args.length > 1
            super(args[1])
            @display_order = args.first
            self.define_singleton_method('display_order=') do |val|
                @display_order = val
            end
            self.define_singleton_method('display_order') do
                @display_order
            end
        end
    end
end