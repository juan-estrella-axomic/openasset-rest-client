class Location

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
    end

end