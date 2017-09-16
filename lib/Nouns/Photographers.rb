class Photographers

    attr_accessor :id, :name

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
            json_obj = Validator::validate_argument(args.first,'Photographers')
        end
    
        @id = json_obj['id']
        @name = json_obj['name']
    end

    def json
        json_data = Hash.new
        json_data[:id] = @id             unless @id.nil?
        json_data[:name] = @name         unless @name.nil?

        return json_data    
    end

end
