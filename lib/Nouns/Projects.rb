require_relative 'NestedProjectKeywordItems'
require_relative 'NestedFieldItems'
require_relative 'NestedAlbumItems'
require_relative '../Validator'
require_relative '../Generic'
require_relative '../JsonBuilder'


class Projects < Generic
    include JsonBuilder
    # @!parse attr_accessor :alive, :code, :code_alias_1, :code_alias_2, :id, :name, :hero_image_id
    attr_accessor :alive, :code, :code_alias_1, :code_alias_2, :id, :name, :hero_image_id

    # @!parse attr_accessor :name_alias_1, :name_alias_2, :project_keywords, :fields, :albums
    attr_accessor :name_alias_1, :name_alias_2, :project_keywords, :fields, :albums

    # @!parse attr_reader :location
    attr_reader :location

    # Creates a Projects object
    #
    # @param args  [String]
    # @return [Projects object]
    #
    # @example
    #         proj =  Projects.new
    #         proj =  Projects.new('My Project','1234.00')
    def initialize(*args)

        if args.length > 1 #We only want 2 non-null ones
            unless args.length == 2 && !args.include?(nil) &&
                  (args[0].is_a?(String) || args[0].is_a?(Integer) || args[0].is_a?(Float)) &&
                  (args[1].is_a?(String) || args[1].is_a?(Integer) || args[1].is_a?(Float))
                warn "Argument Error:\n\tExpected either\n\t1. No Arguments\n\t2. A Hash\n\t" +
                     "3. Two separate string arguments." +
                     " e.g. Projects.new(name,code) in that order." +
                     "\n\tInstead got #{args.inspect} => Creating empty Projects object."
            else
                #grab the first two agruments and set up the json object
                json_obj = {"name" => args[0].to_s, "code" => args[1].to_s}
            end
        else # If a Hash or No argument is passed to the constructor
            json_obj = Validator::validate_argument(args.first,'Projects')
        end
        @alive = json_obj['alive']
        @code = json_obj['code']
        @code_alias_1 = json_obj['code_alias_1']
        @code_alias_2 = json_obj['code_alias_2']
        @hero_image_id = json_obj['hero_image_id']
        @id = json_obj['id']
        @name = json_obj['name']
        @name_alias_1 = json_obj['name_alias_1']
        @name_alias_2 = json_obj['name_alias_2']
        @data_integration_id = json_obj['data_integration_id']
        @location = nil
        @projectKeywords = []
        @fields = []
        @albums = []

        if json_obj['location'] && !json_obj['location'].empty?
            @location = Location.new(json_obj['location'])
        end

        if json_obj['projectKeywords'].is_a?(Array) && !json_obj['projectKeywords'].empty?
            @projectKeywords = json_obj['projectKeywords'].map do |item|
                NestedProjectKeywordItems.new(item['id'])
            end
        end

        if json_obj['fields'].is_a?(Array) && !json_obj['fields'].empty?
            @fields = json_obj['fields'].map do |item|
                NestedFieldItems.new(item['id'], item['values'])
            end
        end

        if json_obj['albums'].is_a?(Array) && !json_obj['albums'].empty?
            @albums = json_obj['albums'].map do |item|
                NestedAlbumItems.new(item['id'])
            end
        end

    end

    # Sets and validates location coordinates on a project
    #
    # @param args  [String, Array, Hash, nil]
    # @return [nil]
    #
    # @example
    #         project = Projects.new('My Project','1234.00')
    #         project.set_coordinates('+90.0','-127.554334')
    #         project.set_coordinates('+90.0,-127.554334')
    #         project.set_coordinates(['+90.0','-127.554334'])
    #         project.set_coordinates({'latitude' => '+90.0', 'longitude' => '-127.554334'})
    def set_coordinates(*args)
        len = args.length
        coordinates = nil

        if len >=2
            coordinates = Validator.validate_coordinates(args[0],args[1])
        else
            coordinates = Validator.validate_coordinates(args.first)
        end

        return if coordinates.empty?

        @location = Location.new
        @location.latitude  = coordinates[0]
        @location.longitude = coordinates[1]
        coordinates
    end
    alias :set_location :set_coordinates

end
