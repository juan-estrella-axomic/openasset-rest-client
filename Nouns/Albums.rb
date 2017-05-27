class Albums

	attr_accessor :all_users_can_modify, :can_modify, :code, :company_album, :created, :description 
	attr_accessor :id, :locked, :my_album, :name, :private_image_count, :public_image_count
	attr_accessor :share_with_all_users, :shared_album, :unapproved_image_count, :updated, :user_id


	def initialize(data=nil)
		json_obj = Validator::validate_argument(data,'Albums') unless data.is_a?(String)
		json_obj = {"name" => data}                            if data.is_a?(String)
		@all_users_can_modify = json_obj['all_users_can_modify']
		@can_modify = json_obj['can_modify']                        
		@code = json_obj['code']                                      
		@company_album = json_obj['company_album']                    
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
			nested_file = Struct.new(:display_order, :id)
			@files = json_obj['files'].map do |item|
				nested_file.new(item['display_order'], item['id'])
			end  
		end  

		if json_obj['groups'].is_a?(Array) && !json_obj['groups'].empty?
			group = Struct.new(:can_modifiy,:id)
			@groups = json_obj['groups'].map do |item|
				group.new(item['can_modifiy'], item['id'])
			end
		end

		if json_obj['users'].is_a?(Array) && !json_obj['users'].empty?
			user = Struct.new(:can_modifiy,:id)
			@users = json_obj['users'].map do |item|
				user.new(item['can_modifiy'], item['id'])
			end
		end                 
	end

	def json
		json_data = Hash.new
		json_data[:all_users_can_modify] = @all_users_can_modify 	 unless @all_users_can_modify.nil?
		json_data[:can_modify] = @can_modify                     	 unless @can_modify.nil?
		json_data[:code] = @code                                 	 unless @code.nil?
 		json_data[:company_album] = @company_album               	 unless @company_album.nil?
 		json_data[:created] = @created							 	 unless @created.nil?
 		json_data[:description] = @description	 				 	 unless @description.nil?
 		json_data[:id] = @id  										 unless @id.nil?
 		json_data[:locked] = @locked                           	     unless @locked.nil?
 		json_data[:my_album] = @my_album							 unless @my_album.nil?
 		json_data[:name] = @name								 	 unless @name.nil?
 		json_data[:private_image_count] = @private_image_count       unless @private_image_count.nil?
 		json_data[:public_image_count] = @public_image_count         unless @public_image_count.nil?
 		json_data[:share_with_all_users] = @share_with_all_users     unless @share_with_all_users.nil?
 		json_data[:shared_album] = @shared_album				     unless @shared_album
 		json_data[:unapproved_image_count] = @unapproved_image_count unless @unapproved_image_count.nil?
 		json_data[:updated] = @updated  					         unless @updated
 		json_data[:user_id] = @user_id 					             unless @user_id.nil?
		json_data[:files] = @files.map { |obj| obj.to_h }			 unless @files.empty?
		json_data[:groups] = @groups.map { |obj| obj.to_h }			 unless @groups.empty?
		json_data[:users] = @users.map { |obj| obj.to_h }			 unless @users.empty?
 
 		return json_data
	end
end