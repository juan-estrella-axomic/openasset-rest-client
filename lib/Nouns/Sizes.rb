require_relative '../JsonBuilder'
class Sizes
    include JsonBuilder
    # @!parse attr_accessor :alive, :always_create, :colourspace, :crop_to_fit, :description, :display_order
    attr_accessor :alive, :always_create, :colourspace, :crop_to_fit, :description, :display_order

    # @!parse attr_accessor :file_format, :height, :id, :name, :original, :postfix, :protected, :quality
    attr_accessor :file_format, :height, :id, :name, :original, :postfix, :protected, :quality

    # @!parse attr_accessor :size_protected, :use_for_contact_sheet, :use_for_power_point, :use_for_zip
    attr_accessor :size_protected, :use_for_contact_sheet, :use_for_power_point, :use_for_zip

    # @!parse attr_accessor :width, :x_resolution, :y_resolution
    attr_accessor :width, :x_resolution, :y_resolution

    # Creates a Sizes object
    #
    # @param args [ Hash, String, Integer, or nil] Default => nil
    # @return [Sizes object]
    #
    # @example
    #         size =  Sizes.new
    #         size =  Sizes.new(postfix,file_format,colourspace,width,height,always_create)
    #         size =  Sizes.new('pptlarge','jpg','rgb','6000','4000',true)
    def initialize(*args)
        json_obj = nil
        if args.length > 1 #We only want one arguement or 6 non-null ones
            unless args.length == 6 && !args.include?(nil) && args[0].is_a?(String) && args[1].is_a?(String) && args[2].is_a?(String) &&
                ((args[3].is_a?(String) && ((args[3] =~ /^[0-9]$/) == 0)) || args[3].is_a?(Integer))

                warn "Argument Error:\n\tExpected either\n\t1. No Arguments\n\t2. A Hash\n\t" +
                     "3. Two separate string arguments." +
                     " e.g. Sizes.new(postfix,file_format,colourspace,width,height,always_create) in that order." +
                     "\n\tInstead got #{args.inspect} => Creating empty Sizes object."
                json_obj = {} # return empty object
            else
                #set grab the agruments and set up the json object
                #set the always create flag to the format expected by the api '0' or '1'
                json_obj = {}
                always_create_flag = '0'
                always_create_flag = '1'   if args[5] == true || args[5] == 1 || args[5] == '1' || args[5].downcase == 'true'

                json_obj['postfix']       = args[0]
                json_obj['file_format']   = args[1]
                json_obj['colourspace']   = args[2]
                json_obj['width']         = args[3]
                json_obj['height']        = args[4]
                json_obj['always_create'] = always_create_flag
            end
        else
            json_obj = Validator::validate_argument(args.first,'Sizes')
        end

        @alive = json_obj['alive']
        @always_create = json_obj['always_create']
        @colourspace = json_obj['colourspace']      #enumerator
        @crop_to_fit = json_obj['crop_to_fit']
        @description = json_obj['description']
        @display_order = json_obj['display_order']
        @file_format = json_obj['file_format']
        @height = json_obj['height']
        @id = json_obj['id']
        @name = json_obj['name']
        @original = json_obj['original']
        @postfix = json_obj['postfix']
        @protected = json_obj['protected']
        @quality = json_obj['quality']
        @size_protected = json_obj['size_protected']
        @use_for_contact_sheet = json_obj['use_for_contact_sheet']
        @use_for_power_point = json_obj['use_for_power_point']
        @use_for_zip = json_obj['use_for_zip']
        @width = json_obj['width']
        @x_resolution = json_obj['x_resolution']
        @y_resolution = json_obj['y_resolution']
    end
end