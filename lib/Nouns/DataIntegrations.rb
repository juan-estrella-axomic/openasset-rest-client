class DataIntegrations

    # @!parse attr_accessor :address, :alive, :id, :name, :display_order, :version
    attr_accessor :address, :alive, :id, :name, :display_order, :version

    # Creates a DataIngetrations object (GET ONLY! No PUT,POST,DELETE)
    #
    # @param value [Hash, nil] Takes a hash or no argument
    # @return [DataIngetrations object]
    #
    # @example 
    #          obj = DataIntegrations.new => Empty obj 
    #          obj = DataIntegrations.new(:address => "http://example.vision.com/Vision/VisionWS.asmx", :name => "Test", :display_order => "1")
    def initialize(value)
        json_obj = Validator::validate_argument(value,'DataIntegrations')

        @address       = json_obj['address']
        @alive         = json_obj['alive']
        @id            = json_obj['id']
        @name          = json_obj['name']
        @display_order = json_obj['display_order']
        @version       = json_obj['version']
    end

    def json
        Hash.new.tap do |json_data|
            json_data[:address]       = @address          unless @address.nil?
            json_data[:alive]         = @alive            unless @alive.nil?
            json_data[:id]            = @id               unless @id.nil?
            json_data[:name]          = @name             unless @name.nil?
            json_data[:display_order] = @display_order    unless @display_order.nil?
            json_data[:version]       = @version          unless @version.nil?
        end
    end

end