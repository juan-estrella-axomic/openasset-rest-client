require_relative '../JsonBuilder'
class KeywordCategories
    include JsonBuilder
    attr_accessor :category_id, :code, :display_order, :id, :name

    def initialize(*args)
        json_obj = nil

        if args.length > 1 #We only want one Hash arguement or 2 non-null ones
            unless args.length == 2 && !args.include?(nil) && (args[0].is_a?(String) || args[0].is_a?(Integer)) && (!args[1].is_a?(String) || !args[1].is_a?(Integer))
                warn "Argument Error:\n\tExpected either\n\t1. No Arguments\n\t2. A Hash\n\t" +
                     "3. Two separate string arguments." +
                     " e.g. KeywordCategories.new(name,category_id) in that order." +
                     "\n\tInstead got #{args.inspect} => Creating empty KeywordCategories object."
                json_obj = {}
            else
                #set grab the agruments and set up the json object
                json_obj = {"name" => args[0].to_s, "category_id" => args[1].to_s}
            end
        else
            json_obj = Validator::validate_argument(args.first,'KeywordCategories')
        end
        @category_id = json_obj['category_id']
        @code = json_obj['code']
        @display_order = json_obj['display_order']
        @id = json_obj['id']
        @name = json_obj['name']
    end
end