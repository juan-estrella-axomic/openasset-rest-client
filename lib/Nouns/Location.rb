require_relative '../Validator'
class Location
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

    def json
        json_data = Hash.new

        json_data[:address] = @address               unless @address.nil?
        json_data[:city] = @city                     unless @city.nil?
        json_data[:country] = @country               unless @country.nil?
        json_data[:google_id] = @google_id           unless @google_id.nil?
        json_data[:latitude] = @latitude             unless @latitude.nil?
        json_data[:longitude] = @longitude           unless @longitude.nil?
        json_data[:name] = @name                     unless @name.nil?
        json_data[:postal_code] = @postal_code       unless @postal_code.nil?
        json_data[:state] = @state                   unless @state.nil?
        json_data[:street] = @street                 unless @street.nil?
        json_data[:street_number] = @street_number   unless @street_number.nil?

        return json_data
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