class ProjectKeywordCategories

    # @!parse attr_accessor :code, :display_order, :id, :name
    attr_accessor :code, :display_order, :id, :name
    
    # Creates a ProjectKeywordCategories object
    #
    # @param arg [Hash, String] Takes a Hash, String or no argument 
    # @return [ProjectKeywordCategories object]
    #
    # @example 
    #         proj_kwd_category =  ProjectKeywordCategories.new
    #         proj_kwd_category =  ProjectKeywordCategories.new('MyKCat')
    def initialize(arg=nil)
        json_obj = nil    
        
        if arg.is_a?(String) || arg.is_a?(Integer)
            json_obj = {"name" => args[0].to_s}
        elsif arg.is_a?(Hash) || arg == nil
            json_obj = (arg) ? arg : Hash.new
        else 
            warn "Argument Error:\n\tExpected either\n\t1. No Arguments\n\t2. A Hash\n\t" + 
                        "3. One string argument." +
                        " e.g. ProjectKeywordCategories.new(name)." + 
                        "\n\tInstead got #{args.inspect}"
            exit
        end
        
        @code = json_obj['code']
        @display_order = json_obj['display_order']
        @id = json_obj['id']
        @name = json_obj['name']
    end

    def json
        json_data = Hash.new
        json_data[:code] = @id                          unless @code.nil?
        json_data[:display_order] = @display_order      unless @display_order.nil?
        json_data[:id] = @id                            unless @id.nil?
        json_data[:name] = @name                        unless @name.nil?

        return json_data    
    end

end