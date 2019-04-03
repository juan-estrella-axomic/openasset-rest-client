require_relative '../JsonBuilder'
class Photographers
    include JsonBuilder
    # @!parse attr_accessor :id, :name
    attr_accessor :id, :name

    # Creates a Photographers object
    #
    # @param args [String] Takes a String or no argument
    # @return [Photographers object]
    #
    # @example
    #         photographer = Photographers.new
    #         photographer = Photographers.new('John Smith')
    def initialize(*args)
        json_obj = nil

        if args.length > 0 && args.first.is_a?(String) #Make sure only one argument is passed
            unless args.first.is_a?(String) || args.first.is_a?(Integer)
                warn "Argument Error:\n\tExpected either\n\t1. No Arguments\n\t2. A Hash\n\t" +
                        "3. One string argument." +
                        " e.g. Photographers.new(name)." +
                        "\n\tInstead got #{args.inspect} => Creating empty Photographers object."
            else
                json_obj = {"name" => args.first.to_s}
            end
        else
            #Grab the agrument and set up the json object
            json_obj = Validator.validate_argument(args.first,'Photographers')
        end

        @id = json_obj['id']
        @name = json_obj['name']
    end
end
