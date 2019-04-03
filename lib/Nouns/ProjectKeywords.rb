require_relative '../JsonBuilder'
class ProjectKeywords
    include JsonBuilder
    # @!parse attr_accessor :id, :name, :project_count, :project_keyword_category_id
    attr_accessor :id, :name, :project_count, :project_keyword_category_id

    # Creates a ProjectKeywords object
    #
    # @param args  [String]
    # @return [ProjectKeywords object]
    #
    # @example
    #         proj_kwd =  ProjectKeywords.new
    #         proj_kwd =  ProjectKeywords.new('exterior','5')
    def initialize(*args)

        if args.length > 1 #We only want no arguments or 2 non-null ones
            if args.length != 2 || args.include?(nil) || (!args[0].is_a?(String) && !args[0].is_a?(Integer)) || (!args[1].is_a?(String) && !args[1].is_a?(Integer))
                warn "Argument Error:\n\tExpected either\n\t1. No Arguments\n\t2. A Hash\n\t" +
                     "3. Two separate string arguments." +
                     " e.g. ProjectKeywords.new(name,project_keyword_category_id) in that order." +
                     "\n\tInstead got #{args.inspect} => Creating empty ProjectKeywords object."
            else
                #set grab the agruments and set up the json object
                json_obj = {"name" => args[0].to_s, "project_keyword_category_id" => args[1].to_s}
            end
        else
            json_obj = Validator.validate_argument(args.first,'ProjectKeywords')
        end

        @id = json_obj['id']
        @name = json_obj['name']
        @project_count = json_obj['project_count']
        @project_keyword_category_id = json_obj['project_keyword_category_id']
    end
end