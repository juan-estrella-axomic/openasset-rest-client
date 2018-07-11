require_relative 'SearchItems'
require_relative 'NestedGroupItems'
require_relative 'NestedUserItems'
require_relative '../JsonBuilder'

class Searches
    include JsonBuilder

    # @!parse attr_accessor :all_users_can_modify, :approved_company_search, :can_modify, :code
    attr_accessor :all_users_can_modify, :approved_company_search, :can_modify, :code

    # @!parse attr_accessor :company_saved_search, :created, :id, :locked, :name, :saved, :search_items
    attr_accessor :company_saved_search, :created, :id, :locked, :name, :saved, :search_items

    # @!parse attr_accessor :share_with_all_users, :updated, :user_id, :search_items, :groups, :users
    attr_accessor :share_with_all_users, :updated, :user_id, :search_items, :groups, :users

    # Creates a Searches object
    #
    # @param args [(String,SearchItems object) or nil] Default => nil
    # @return [Searches object]
    #
    # @example
    #         search =  Searches.new
    #         search =  Searches.new('search1',search_items_object)
    def initialize(*args)
        json_obj = nil

        if args.length > 1 #We only want one arguement or 2 non-null ones
            arg1 = args[0]
            arg2 = args[1].is_a?(Array) ? args[1] : [ args[1] ]
            if !args.include?(nil) && arg1.is_a?(String) && arg2.first.is_a?(SearchItems)
                 #set grab the agruments and set up the json object
                 json_obj = { "name" => arg1, "search_items" => arg2 }
            else
                warn "Argument Error:\n\tExpected either\n\t1. No Arguments\n\t2. A Hash\n\t" +
                     "3. Two separate arguments. The first as a string and the second as a SearchItems object" +
                     " e.g. Searches.new(name,search_items_object) in that order." +
                     "\n\tInstead got #{args.inspect} => Creating empty Searches object."
                json_obj = {}
            end
        else
            json_obj = Validator::validate_argument(args.first,'Searches')
        end

        @all_users_can_modify = json_obj['all_users_can_modify']
        @approved_company_search = json_obj['approved_company_search']
        @can_modify = json_obj['can_modify']
        @code = json_obj['code']
        @company_saved_search = json_obj['company_saved_search']
        @created = json_obj['created']                             #time
        @id = json_obj['id']
        @locked = json_obj['locked']
        @name = json_obj['name']
        @saved = json_obj['saved']
        @share_with_all_users = json_obj['share_with_all_users']
        @updated = json_obj['updated']                             #datetime
        @user_id = json_obj['user_id']
        @search_items = []
        @groups = []
        @users = []

        if json_obj['search_items'].is_a?(Array) && !json_obj['search_items'].empty?
            #turn the nested search items from the json into objects
            @search_items = json_obj['search_items'].map do |item|
                item.is_a?(Hash) ? SearchItems.new(item) : item
            end
        end

        if json_obj['groups'].is_a?(Array) && !json_obj['groups'].empty?
            @groups = json_obj['groups'].map do |item|
                NestedGroupItems.new(item['can_modify'], item['id'])
            end
        end

        if json_obj['users'].is_a?(Array) && !json_obj['users'].empty?
            @users = json_obj['users'].map do |item|
                NestedUserItems.new(item['can_modify'], item['id'])
            end
        end

    end
end