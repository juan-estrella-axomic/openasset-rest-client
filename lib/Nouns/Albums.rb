# Albums class
#
# @author Juan Estrella
require_relative '../Generic'
require_relative '../Validator'
require_relative '../JsonBuilder'
require_relative 'NestedGroupItems'
require_relative 'NestedFileItems'
require_relative 'NestedUserItems'


class Albums < Generic

    include JsonBuilder
    # @!parse attr_accessor :all_users_can_modify, :can_modify, :code, :company_album, :created, :description, :approved_company_album
    attr_accessor :all_users_can_modify, :can_modify, :code, :company_album, :created, :description, :approved_company_album

    # @!parse attr_accessor :id, :locked, :my_album, :name, :private_image_count, :public_image_count
    attr_accessor :id, :locked, :my_album, :name, :private_image_count, :public_image_count

    # @!parse attr_accessor :share_with_all_users, :shared_album, :unapproved_image_count, :updated, :user_id, :files, :groups, :users
    attr_accessor :share_with_all_users, :shared_album, :unapproved_image_count, :updated, :user_id, :files, :groups, :users

    # Creates an Albums object
    #
    # @param data [Hash, nil] Takes a JSON object/Hash or no argument
    # @return [Albums object]
    #
    # @example
    #         album = Albums.new
    def initialize(data=nil)
        json_obj = Validator::validate_argument(data,'Albums') unless data.is_a?(String)
        json_obj = {"name" => data}                            if data.is_a?(String)
        @all_users_can_modify = json_obj['all_users_can_modify']
        @can_modify = json_obj['can_modify']
        @code = json_obj['code']
        @company_album = json_obj['company_album']
        @approved_company_album = json_obj['approved_company_album']
        @created = json_obj['created']
        @description = json_obj['description']
        @id = json_obj['id']
        @locked = json_obj['locked']
        @my_album = json_obj['my_album']
        @name = json_obj['name']
        @private_image_count = json_obj['private_image_count']
        @public_image_count = json_obj['public_image_count']
        @share_with_all_users = json_obj['share_with_all_users']
        @shared_album = json_obj['shared_album']
        @unapproved_image_count = json_obj['unapproved_image_count']
        @updated = json_obj['updated']
        @user_id = json_obj['user_id']
        @files = []
        @groups = []
        @users = []

        #assign values to these instance variables if they come
        #in from get request. Ohtherwise leave them empty. This is
        #for when empty objects are created

        if json_obj['files'].is_a?(Array) && !json_obj['files'].empty?
            #nested_file = Struct.new(:display_order, :id)
            @files = json_obj['files'].map do |item|
                NestedFileItems.new(item['display_order'], item['id'])
                #nested_file.new(item['display_order'], item['id'])
            end
        end

        if json_obj['groups'].is_a?(Array) && !json_obj['groups'].empty?
            #group = Struct.new(:can_modifiy,:id)
            @groups = json_obj['groups'].map do |item|
                NestedGroupItems.new(item['can_modifiy'], item['id'])
                #group.new(item['can_modifiy'], item['id'])
            end
        end

        if json_obj['users'].is_a?(Array) && !json_obj['users'].empty?
            #user = Struct.new(:can_modifiy,:id)
            @users = json_obj['users'].map do |item|
                NestedUserItems.new(item['can_modifiy'], item['id'])
                #user.new(item['can_modifiy'], item['id'])
            end
        end
    end

end