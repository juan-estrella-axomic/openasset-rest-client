require_relative 'SearchItems.rb'


class Searches
    
    # @!parse attr_accessor :all_users_can_modify, :approved_company_search, :can_modify, :code
    attr_accessor :all_users_can_modify, :approved_company_search, :can_modify, :code

    # @!parse attr_accessor :company_saved_search, :created, :id, :locked, :name, :saved, :search_items
    attr_accessor :company_saved_search, :created, :id, :locked, :name, :saved, :search_items

    # @!parse attr_accessor :share_with_all_users, :updated, :user_id
    attr_accessor :share_with_all_users, :updated, :user_id
    
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
            unless args.length == 2 && !args.include?(nil) && args[0].is_a?(String) && args[1].is_a?(Array) && 
                    (args[1].first.is_?(NilClass) || args[1].first.is_a?(SearchItems))
                warn "Argument Error:\n\tExpected either\n\t1. No Arguments\n\t2. A Hash\n\t" + 
                     "3. Two separate arguments. The first as a string and the second as a SearchItems object" +
                     " e.g. Searches.new(name,search_items_object) in that order." + 
                     "\n\tInstead got #{args.inspect} => Creating empty Searches object."
                json_obj = {}
            else
                #set grab the agruments and set up the json object
                json_obj = {"name" => args[0], "search_items" => args[1]}
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
                SearchItems.new(item)
            end
        end

        if json_obj['groups'].is_a?(Array) && !json_obj['groups'].empty?
            group = Struct.new(:can_modify, :id)
            @groups = json_obj['groups'].map do |item|
                group.new(item['can_modify'], item['id'])
            end            
        end

        if json_obj['users'].is_a?(Array) && !json_obj['users'].empty?
               user = Struct.new(:can_modify, :id)
               @users = json_obj['users'].map do |item|
                   user.new(item['can_modify'], item['id'])
               end
        end   
  
    end

    def json
        json_data = Hash.new
        json_data[:all_users_can_modify] = @all_users_can_modify         unless @all_users_can_modify.nil?
        json_data[:approved_company_search] = @approved_company_search   unless @display_order.nil?
        json_data[:can_modify] = @can_modify                             unless @can_modify.nil?
        json_data[:code] = @code                                         unless @code.nil?
        json_data[:company_saved_search] = @company_saved_search         unless @company_saved_search.nil?
        json_data[:created] = @created                                   unless @created.nil?
        json_data[:id] = @id                                             unless @id.nil?
        json_data[:locked] = @locked                                     unless @locked.nil?
        json_data[:name] = @name                                         unless @name.nil?
        json_data[:saved] = @saved                                       unless @saved.nil?
        json_data[:share_with_all_users] = @share_with_all_users         unless @share_with_all_users.nil?
        json_data[:updated] = @updated                                   unless @updated.nil?
        json_data[:user_id] = @user_id                                   unless @updated.nil?
        
        unless @search_items.empty?
            #convert nested SearchItems objects into JSON objects NOT JSON strings
            json_data[:search_items] = @search_items.map do |item|
                item.json
            end
        end

        unless @groups.empty?
            json_data[:groups] = @groups.map do |item|
                item.to_h
            end
        end

        unless @users.empty?
            json_data[:users] = @users.map do |item|
                item.to_h
            end
        end    
        
        return json_data
    end

end