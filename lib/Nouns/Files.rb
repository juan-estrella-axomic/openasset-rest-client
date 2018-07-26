require_relative 'NestedSizeItems'
require_relative 'NestedFieldItems'
require_relative 'NestedKeywordItems'
require_relative 'NestedAlbumItems'
require_relative '../JsonBuilder'
require_relative '../Generic'

# Files class
#
# @author Juan Estrella
class Files < Generic

    include JsonBuilder

    # @!parse attr_accessor :access_level, :alternate_store_id, :caption, :category_id, :click_count, :contains_audio
    attr_accessor :access_level, :alternate_store_id, :caption, :category_id, :click_count, :contains_audio

    # @!parse attr_accessor :contains_video, :copyright_holder_id, :created, :description, :download_count, :duration
    attr_accessor :contains_video, :copyright_holder_id, :created, :description, :download_count, :duration

    # @!parse attr_accessor :filename, :id, :md5_at_upload, :md5_now, :original_filename, :photographer_id, :project_id, :alive
    attr_accessor :filename, :id, :md5_at_upload, :md5_now, :original_filename, :photographer_id, :project_id, :alive

    # @!parse attr_accessor :rank, :rotation_since_upload, :uploaded, :user_id, :keywords, :fields, :sizes, :albums
    attr_accessor :rank, :rotation_since_upload, :uploaded, :user_id, :keywords, :fields, :sizes, :albums

    # @!parse attr_accessor :processing_failures, :replaced_user_id, :video_frames_per_second, :updated, :recheck, :replaced, :rotate_degrees
    attr_accessor :processing_failures, :replaced_user_id, :video_frames_per_second, :updated, :recheck, :replaced, :rotate_degrees

    # Creates a Files object
    #
    # @param args [Hash, String Argument list, nil] Takes a JSON object/Hash or no argument
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
        @deleted = json_obj['deleted']
        @processing_failures = json_obj['processing_failures']
        @project_id = json_obj['project_id']
        @alive = json_obj['alive']
        @rank = json_obj['rank']
        @recheck = json_obj['recheck']
        @replaced = json_obj['replaced']
        @replaced_user_id = json_obj['replaced_user_id']
        @rotation_since_upload = json_obj['rotation_since_upload']
        @uploaded = json_obj['uploaded']
        @user_id = json_obj['user_id']
        @rotate_degrees = json_obj['rotate_degrees']
        @updated = json_obj['updated']
        @video_frames_per_second = json_obj['video_frames_per_second']
        @keywords = []
        @fields = []
        @sizes = []
        @albums = []

        if json_obj['fields'].is_a?(Array) && !json_obj['fields'].empty?
            #convert nested size json into objects
            #nested_field = Struct.new(:id, :values)
            @fields = json_obj['fields'].map do |item|
                NestedFieldItems.new(item['id'], item['values'])
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

        if json_obj['albums'].is_a?(Array) && !json_obj['albums'].empty?
            #convert nested keywords into objects
            @albums = json_obj['albums'].map do |item|
                NestedAlbumItems.new(item)
            end
        end

    end

    # Retrieves the file path for specified image size.
    #
    # @param size [String, Integer] Takes image size id or postfix string like 'medium'
    #                              Defaults to id of 1 which provides path to original image size
    # @return [String, false] Returns image download path or empty string when error is encountered.
    #
    # @example
    #          file_obj.get_image_size_file_path('1')
    #          file_obj.get_image_size_file_path('medium')
    def get_image_size_file_path(size='1') #Always returns the original by default
        if (size.is_a?(String) && size.to_i > 0) || size.is_a?(Integer)
            #Look for the nested image size containing the id passed as the search_parameter
            image = @sizes.find {|item| item.id.to_s == size.to_s}
            unless image
                puts "Error: Image size id not found. Check if the image size " +
                     "was created in OpenAsset."
                return false
            else
                #image.http_root.gsub('//','') + image.http_relative_path
                image.http_root.gsub('//','') + image.relative_path
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