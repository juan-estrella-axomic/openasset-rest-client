# Groups class
#
# @author Juan Estrella
class Users

    # @!parse attr_accessor :alive, :full_name, :id, :username, :groups
    attr_accessor :alive, :full_name, :id, :username, :groups

    # Creates a Users object
    #
    # @param args [ Hash, 2 Strings, or nil ] Default => nil
    # @return [ Users object]
    #
    # @example
    #         user = Users.new
    #         user = Users.new("jdoe@contoso.com","John Doe","pass")
    #         user = Users.new({:username => "jdoe@contoso.com", :full_name => "John Doe", :password => "pass"})
    def initialize(*args)
        json_obj = {}

        if args.length < 3 && !args.first.is_a?(Hash)
            msg = "Expected username, fullname, and password or a Hash\n" +
                  "\tInstead got #{args.inspect}.\nCreating empty user object."
            Logger.error(msg)
        elsif args.first.is_a?(String) # Assume three string args were passed
            json_obj['username']  = args[0]
            json_obj['full_name'] = args[1]
            json_obj['password']  = args[3]
        else                        # Assume a Hash or nil was passed
            json_obj = Validator::validate_argument(args.first,'Users')
        end

        @alive = json_obj['alive']
        @full_name = json_obj['full_name']
        @id = json_obj['id']
        @username = json_obj['username']
        @password = json_obj['password'] # only used for POST and PUT
        @groups = []

        if json_obj['groups'].is_a?(Array) && !json_obj['groups'].empty?
            @groups = json_obj['groups'].map do |item|
                NestedGroupItems.new(item['id'])
            end
        end
    end

    def json
        json_data = Hash.new
        json_data[:alive] = @alive                            unless @alive.nil?
        json_data[:full_name] = @full_name                    unless @full_name.nil?
        json_data[:id] = @id                                  unless @id.nil?
        json_data[:username] = @username                      unless @username.nil?
        json_data[:password] = @password                      unless @password.nil?

        unless @groups.empty?
            json_data[:groups] = @groups.map do |item|
                item.json
            end
        end

        return json_data
    end
end