# Groups class
#
# @author Juan Estrella
require_relative '../JsonBuilder'
class Groups

    include JsonBuilder

    # @!parse attr_accessor :hidden, :alive, :id, :name, :default_for_new_users, :expires, :expiry_date, :users
    attr_accessor :hidden, :alive, :id, :name, :default_for_new_users, :expires, :expiry_date, :users

    # Creates a Groups object
    #
    # @param args [ Hash, 2 Strings, or nil ] Default => nil
    # @return [ Groups object]
    #
    # @example
    #         user = Groups.new
    #         user = Groups.new("Marketing")
    #         user = Groups.new({:name=> "Marketing"})
    def initialize(*args)
        json_obj = {}

        if args.first.is_a?(String) # Assume two string args were passed
            json_obj['name'] = args.first
        else                        # Assume a Hash or nil was passed
            json_obj = Validator.validate_argument(args.first,'Groups')
        end

        @hidden = json_obj['hidden']
        @alive = json_obj['alive']
        @id = json_obj['id']
        @name = json_obj['name']
        @default_for_new_users = json_obj['default_for_new_users']
        @expires = json_obj['expires']
        @expiry_date = json_obj['expiry_date']
        @users = []

        if json_obj['users'].is_a?(Array) && !json_obj['users'].empty?
            @users = json_obj['users'].map do |item|
                NestedUserItems.new(item['id'])
            end
        end
    end

end