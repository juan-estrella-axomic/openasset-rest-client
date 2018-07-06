require_relative '../Validator'
require_relative '../JsonBuilder'
class Location
    include JsonBuilder
    # @!parse attr_accessor :address, :city, :country, :google_id, :latitude, :longitude
    attr_accessor :address, :city, :country, :google_id, :latitude, :longitude

    # @!parse attr_accessor :name, :postal_code, :state, :street, :street_number
    attr_accessor :name, :postal_code, :state, :street, :street_number

    # Creates a Location object
    #
    # @param args  [String, Array, Hash, nil]
    # @return [Location object]
    #
    # @example
    #         location_obj =  Location.new
    #         location_obj =  Location.new({'address' => '123 main st', 'latitude' => '+90.0', 'longitude' => '-127.554334', ...})
    def initialize(*args)

        json_obj = Validator::validate_argument(args.first,'Location')

        @address = json_obj['address']
        @city = json_obj['city']
        @country = json_obj['country']
        @google_id = json_obj['google_id']
        @latitude = json_obj['latitude']
        @longitude = json_obj['longitude']
        @name = json_obj['name']
        @postal_code = json_obj['postal_code']
        @state = json_obj['state']
        @street = json_obj['street']
        @street_number = json_obj['street_number']
    end

    # Sets and validates location coordinates on a location object
    #
    # @param args  [String, Array, Hash, nil]
    # @return [nil]
    #
    # @example
    #         location_obj.set_coordinates('+90.0','-127.554334')
    #         location_obj.set_coordinates('+90.0,-127.554334')
    #         location_obj.set_coordinates(['+90.0','-127.554334'])
    #         location_obj.set_coordinates({'latitude' => '+90.0', 'longitude' => '-127.554334'})
    def set_coordinates(*args)
        len = args.length
        coordinates = nil

        if len >=2
            coordinates = Validator.validate_coordinates(args[0],args[1])
        else
            coordinates = Validator.validate_coordinates(args.first)
        end

        return if coordinates.empty?

        @location.latitude  = coordinates[0]
        @location.longitude = coordinates[1]
        coordinates
    end
end