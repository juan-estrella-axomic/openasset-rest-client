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
    # @param args [ Hash or nil] Default => nil
    # @return [Sizes object]
    #
    # @example
    #         size =  Sizes.new
    #         size =  Sizes.new({
    #                'postfix'       => postfix,
    #                'file_format'   => 'jpg',
    #                'colourspace'   => 'RGB',
    #                'width'         => 1920,
    #                'height'        => 1080,
    #                'always_create' => 1,
    #                'x_resolution'  => 72,
    #                'y_resolution'  => 72
    #            })
    def initialize(data=nil)
        json_obj = Validator.validate_argument(data,'Sizes')

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