class Users
    
    # @!parse attr_accessor :alive, :full_name, :id, :username
    attr_accessor :alive, :full_name, :id, :username
    
    # Creates a Users object (Only Permits GET requests)
    #
    # @param data [ Hash or nil ] Default => nil
    # @return [ Users object]
    #
    # @example 
    #         user = Users.new
    def initialize(data=nil)
        json_obj = Validator::validate_argument(data,'Users')
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