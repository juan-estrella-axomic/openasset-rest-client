class AlternateStores

	attr_accessor :id, :name, :storage_name

	def initialize(data=nil)
		json_obj = Validator::validate_argument(data,'AlternateStores')
		@id = json_obj['id']                      
		@name = json_obj['name']                  
		@storage_name = json_obj['storage_name']  
	end

	def json
		json_data = Hash.new
		json_data[:id] = @id                      unless @id.nil?
		json_data[:name] = @name                  unless @name.nil?
		json_data[:storage_name] = @storage_name  unless @storage_name.nil?

		return json_data
	end

end