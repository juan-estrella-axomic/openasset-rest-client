require_relative 'NestedSizeItems.rb'
require_relative 'NestedKeywordItems.rb'

# Files class
# 
# @author Juan Estrella
class Files

    @@encoding_options = {
        :invalid           => :replace,  # Replace invalid byte sequences
        :undef             => :replace,  # Replace anything not defined in ASCII
        :replace           => '',        # Use a blank for those replacements
        :universal_newline => true       # Always break lines with \n
    }

    # @!parse attr_accessor :access_level, :alternate_store_id, :caption, :category_id, :click_count, :contains_audio
    attr_accessor :access_level, :alternate_store_id, :caption, :category_id, :click_count, :contains_audio

    # @!parse attr_accessor :contains_video, :copyright_holder_id, :created, :description, :download_count, :duration
    attr_accessor :contains_video, :copyright_holder_id, :created, :description, :download_count, :duration

    # @!parse attr_accessor :filename, :id, :md5_at_upload, :md5_now, :original_filename, :photographer_id, :project_id
    attr_accessor :filename, :id, :md5_at_upload, :md5_now, :original_filename, :photographer_id, :project_id

    # @!parse attr_accessor :rank, :rotation_since_upload, :uploaded, :user_id, :keywords, :fields, :sizes
    attr_accessor :rank, :rotation_since_upload, :uploaded, :user_id, :keywords, :fields, :sizes

    # Creates an Files object
    #
    # @param args [Hash, Argument list, nil] Takes a JSON object/Hash or no argument 
    # @return [Files object]
    #
    # @example 
    #          file = Files.new
    #          file = Files.new(cat_id,'imagename.jpg')
    #          file = Files.new(cat_id,'imagename.jpg',proj_id)
    #          file = Files.new(cat_id,'imagename.jpg',proj_id,album_id)
    #          file = Files.new(cat_id,'imagename.jpg',proj_id,album_id,'img.jpg')
    #          file = Files.new(cat_id,'imagename.jpg',proj_id,album_id,'img.jpg,'90')
    def initialize(*args)
        json_obj = nil

        if args.length > 1
            len = args.length
            json_obj = Hash.new
            #Allows user to use different number or arguments in the constructor
            case len
            when 2
                json_obj['category_id']       = args[0]
                json_obj['original_filename'] = args[1]
            when 3
                json_obj['category_id']       = args[0]
                json_obj['original_filename'] = args[1]
                json_obj['project_id']        = args[2]
            when 4
                json_obj['category_id']       = args[0]
                json_obj['original_filename'] = args[1]
                json_obj['project_id']        = args[2]
                json_obj['album_id']          = args[3]
            when 5
                json_obj['category_id']       = args[0]
                json_obj['original_filename'] = args[1]
                json_obj['project_id']        = args[2]
                json_obj['album_id']          = args[3]
                json_obj['partial_filename']  = args[4]
            when 6
                json_obj['category_id']       = args[0]
                json_obj['original_filename'] = args[1]
                json_obj['project_id']        = args[2]
                json_obj['album_id']          = args[3]
                json_obj['partial_filename']  = args[4]
                json_obj['rotate_degrees']    = args[5]
            else
                warn "Argument Error:\n\tExpected either\n\t1. No Arguments\n\t2. A Hash\n\t" + 
                     "3. Minimum of 2 arguments e.g. Files.new(category_id,original_filename," + 
                     "project_id,album_id,partial_filename,rotate_degrees) " + 
                     "in that order. First 2 arguments are required (if any are specified)." +
                     "\n\tInstead got #{args.inspect} => Creating empty Files object."
            end
        else
            json_obj = Validator::validate_argument(args.first,'Files')
        end
          
        @access_level = json_obj['access_level']
        @alternate_store_id = json_obj['alternate_store_id']
        @caption = json_obj['caption']
        @category_id = json_obj['category_id']
        @click_count = json_obj['click_count']
        @contains_audio = json_obj['contains_audio']
        @contains_video = json_obj['contains_video']
        @copyright_holder_id = json_obj['copyright_holder_id']
        @created = json_obj['created']                           #date
        @description = json_obj['description']
        @download_count = json_obj['download_count']
        @duration = json_obj['duration']
        @filename = json_obj['filename']
        @id = json_obj['id']
        @md5_at_upload = json_obj['md5_at_upload']
        @md5_now = json_obj['md5_now']
        @original_filename = json_obj['original_filename']
        @photographer_id = json_obj['photographer_id']
        @project_id = json_obj['project_id']
        @rank = json_obj['rank']
        @rotation_since_upload = json_obj['rotation_since_upload']
        @uploaded = json_obj['uploaded']     
        @user_id = json_obj['user_id']                       
        @rotate_degrees = json_obj['rotate_degrees']
        @keywords = []
        @fields = []
        @sizes = []

        if json_obj['fields'].is_a?(Array) && !json_obj['fields'].empty?
            #convert nested size json into objects
            nested_field = Struct.new(:id, :values)
            @fields = json_obj['fields'].map do |item|
                nested_field.new(item['id'], item['values'])
            end
        end

        if json_obj['sizes'].is_a?(Array) && !json_obj['sizes'].empty?
            #convert nested size json into objects
            @sizes = json_obj['sizes'].map do |item|
                NestedSizeItems.new(item)
            end
        end

        if json_obj['keywords'].is_a?(Array) && !json_obj['keywords'].empty?
            #convert nested keywords into objects
            @keywords = json_obj['keywords'].map do |item|
                NestedKeywordItems.new(item)
            end
        end

    end

    # @!visibility private
    def json
        json_data = Hash.new
        json_data[:access_level] = @access_level                      unless @access_level.nil?
        json_data[:alternate_store_id] = @alternate_store_id          unless @alternate_store_id.nil?
        json_data[:caption] = @caption                                unless @caption.nil?
        json_data[:category_id] = @category_id                        unless @category_id.nil?
        json_data[:click_count] = @click_count                        unless @click_count.nil?
        json_data[:contains_audio] = @contains_audio                  unless @contains_audio.nil?
        json_data[:contains_video] = @contains_video                  unless @contains_video.nil?
        json_data[:copyright_holder_id] = @copyright_holder_id        unless @copyright_holder_id.nil?
        json_data[:created] = @created                                unless @created.nil?
        json_data[:description] = @description                        unless @description.nil?
        json_data[:download_count] = @download_count                  unless @download_count.nil?
        json_data[:duration] = @duration                              unless @duration.nil?
        json_data[:filename] = @filename                              unless @filename.nil?
        json_data[:id] = @id                                          unless @id.nil?
        json_data[:md5_at_upload] = @md5_at_upload                    unless @md5_at_upload.nil?
        json_data[:md5_now] = @md5_now                                unless @md5_now.nil?
        json_data[:original_filename] = @original_filename            unless @original_filename.nil?
        json_data[:photographer_id] = @photographer_id                unless @photographer_id.nil?
        json_data[:project_id] = @project_id                          unless @project_id.nil?
        json_data[:rank] = @rank                                      unless @rank.nil?
        json_data[:rotation_since_upload] = @rotation_since_upload    unless @uploaded.nil?
        json_data[:uploaded] = @uploaded                              unless @uploaded.nil?
        json_data[:user_id] = @user_id                                unless @user_id.nil?

        unless @sizes.empty?
            #convert every nested sizes object back to a hash/json object
            json_data[:sizes] = @sizes.map do |item|
                item.json
            end
        end

        unless @keywords.empty?
            #convert every nested keywords object back to hash/json object
            json_data[:keywords] = @keywords.map do |item|
                item.json
            end
        end    

        unless @fields.empty?
            #you get the idea...
            json_data[:fields] = @fields.map do |item| 
                item.to_h 
            end                            
        end
        
        return json_data
    end

    # Retrieves the file path for specified image size.
    #
    # @param search_parameter [String, Integer] Takes image size id or postfix string like 'medium'
    #                              Defaults to id of 1 which provides path to original image size
    # @return [String, false] Returns image download path or empty string when error is encountered.
    #
    # @example 
    #          file_obj.get_image_size_file_path('1')
    #           file_obj.get_image_size_file_path('medium')
    def get_image_size_file_path(size='1') #Always returns the original by default
        if (size.is_a?(String) && size.to_i > 0) || size.is_a?(Integer)
            #Look for the nested image size containing the id passed as the search_parameter
            image = @sizes.find {|item| item.id.to_s == size.to_s}
            unless image
                puts "Error: Image size id not found. Check if the image size " +
                     "was created in OpenAsset."
                return false
            else
                image.http_root.gsub('//','') + image.http_relative_path
            end
        elsif size.is_a?(String)
            #Look for the postfix search_parameter string in the path 
            image = @sizes.find {|item| item.http_relative_path.include?(size.downcase)}
            unless image
                puts "Error: Could not find the postfix value => #{size.inspect}. \n" +
                     "Verify that the image size exists and that the size was generated for file " +
                     "#{@filename.inspect} in OpenAsset."
                return false
            else
                image.http_root.gsub('//','') + image.http_relative_path
            end
        else
            puts "Argument Error for 'get_url' method:\n\t" +
                 "Expected an Integer or Numeric String id value, or the image size postfix name.\n\t" +
                 "Instead got => #{size.inspect}"
            return false
        end
    end

end