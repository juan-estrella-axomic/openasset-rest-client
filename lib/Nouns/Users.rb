# Groups class
# 
# @author Juan Estrella
class Users
    
    # @!parse attr_accessor :alive, :full_name, :id, :username
    attr_accessor :alive, :full_name, :id, :username
    
    # Creates a Users object
    #
    # @param args [ Hash, 2 Strings, or nil ] Default => nil
    # @return [ Users object]
    #
    # @example 
    #         user = Users.new
    #         user = Users.new("jdoe@contoso.com","John Doe")
    #         user = Users.new({:username => "jdoe@contoso.com", :full_name => "John Doe"})
    def initialize(*args)
        json_obj = {}

        if args.first.is_a?(String) # Assume two string args were passed
            json_obj['username']  = args[0]
            json_obj['full_name'] = args[1] || args[0] # Use the username if not specified
        else                        # Assume a Hash or nil was passed
            json_obj = Validator::validate_argument(args.first,'Users')
        end

        @alive = json_obj['alive']
        @full_name = json_obj['full_name']
        @id = json_obj['id']
        @username = json_obj['username']
    end

    def json
        json_data = Hash.new
        json_data[:alive] = @alive                            unless @alive.nil?
        json_data[:full_name] = @full_name                    unless @full_name.nil?
        json_data[:id] = @id                                  unless @id.nil?
        json_data[:username] = @username                      unless @username.nil?
        
        return json_data    
    end
end